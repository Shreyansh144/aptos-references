/// A 2-in-1 module that combines managed_fungible_asset and coin_example into one module that when deployed, the
/// deployer will be creating a new managed fungible asset with the hardcoded supply config, name, symbol, and decimals.
/// The address of the asset can be obtained via get_metadata(). As a simple version, it only deals with primary stores.
module PhotonDevAddress::pat_coin{
    use aptos_framework::fungible_asset::{Self, MintRef, TransferRef, BurnRef, Metadata, FungibleAsset};
    use aptos_framework::object::{Self, Object};
    use aptos_framework::primary_fungible_store;
    use std::error;
    use std::signer;
    use std::string::utf8;
    use std::option;

    /// Only fungible asset metadata owner can make changes.
    const ENOT_OWNER: u64 = 1;
    /// The account is frozen and cannot perform the operation
    const EFROZEN: u64 = 2;
    /// The sender account is frozen and cannot send tokens
    const EFROZEN_SENDING: u64 = 3;
    /// The recipient account is frozen and cannot receive tokens
    const EFROZEN_RECEIVING: u64 = 4;
    /// The account is not frozen so the operation is not allowed
    const ENOT_FROZEN: u64 = 5;
    /// The length of the vectors do not match
    const EARGUMENT_VECTORS_LENGTH_MISMATCH: u64 = 6;
    /// Cannot transfer admin to the same address
    const ESAME_ADMIN: u64 = 7;
    /// Invalid asset
    const EINVALID_ASSET: u64 = 8;
      /// Caller is not authorized to make this call
    const EUNAUTHORIZED: u64 = 9;


    const PAT_NAME: vector<u8> = b"PAT Coin";
    const PAT_SYMBOL: vector<u8> = b"PAt";
    const PAT_DECIMALS: u8 = 8;
    const PROJECT_URI: vector<u8> = b"http://example.com";
    const ICON_URI: vector<u8> = b"http://example.com/favicon.ico";

    #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    struct ManagedFungibleAsset has key {
        mint_ref: MintRef,
        transfer_ref: TransferRef,
        burn_ref: BurnRef,
        admin: address,
        pending_admin: address,
    }

    #[event]
    struct Mint has drop, store {
        to: address,
        amount: u64,
    }

    #[event]
    struct Burn has drop, store {
        from: address,
        store: Object<FungibleStore>,
        amount: u64,
    }

    #[event]
    struct TransferAdmin has drop, store {
        admin: address,
        pending_admin: address,
    }

    #[event]
    struct AcceptAdmin has drop, store {
        old_admin: address,
        new_admin: address,
    }

    #[view]
    public fun pat_address(): address {
        object::create_object_address(&@pat, PAT_SYMBOL)
    }

    #[view]
    public fun metadata(): Object<Metadata> {
        object::address_to_object(pat_address())
    }

    #[view]
    public fun admin(): address acquires Management {
        borrow_global<Management>(pat_address()).admin
    }

    fun init_module(admin: &signer) {
        let constructor_ref = &object::create_named_object(admin, PAT_SYMBOL);
        primary_fungible_store::create_primary_store_enabled_fungible_asset(
            constructor_ref,
            option::none(),
            utf8(PAT_NAME),
            utf8(PAT_SYMBOL),
            PAT_DECIMALS,
            string::utf8(ICON_URI),
            string::utf8(PROJECT_URI),
        );

        let mint_ref = fungible_asset::generate_mint_ref(constructor_ref);
        let burn_ref = fungible_asset::generate_burn_ref(constructor_ref);
        let transfer_ref = fungible_asset::generate_transfer_ref(constructor_ref);
        let metadata_object_signer = object::generate_signer(constructor_ref);
        move_to(
            &metadata_object_signer,
            ManagedFungibleAsset { mint_ref, transfer_ref, burn_ref }
        )
    }

    #[view]
    public fun get_metadata(): Object<Metadata> {
        let asset_address = object::create_object_address(&@PhotonDevAddress, ASSET_SYMBOL);
        object::address_to_object<Metadata>(asset_address)
    }

    public entry fun mint(admin: &signer, to: address, amount: u64) acquires ManagedFungibleAsset {
        let asset = get_metadata();
        let managed_fungible_asset = authorized_borrow_refs(admin, asset);
        let to_wallet = primary_fungible_store::ensure_primary_store_exists(to, asset);
        let fa = fungible_asset::mint(&managed_fungible_asset.mint_ref, amount);
        fungible_asset::deposit_with_ref(&managed_fungible_asset.transfer_ref, to_wallet, fa);
    }

    public entry fun claim(user: &signer, amount: u64) acquires ManagedFungibleAsset {
        let user_addr = signer::address_of(user);
        let asset = get_metadata();
        let transfer_ref = &authorized_borrow_refs_without_owner(asset).transfer_ref;
        let from_wallet = primary_fungible_store::primary_store(@PhotonDevAddress, asset);
        let to_wallet = primary_fungible_store::ensure_primary_store_exists(user_addr, asset);
        fungible_asset::transfer_with_ref(transfer_ref, from_wallet, to_wallet, amount);
    }

    public entry fun SpendOnProtocol(from: &signer, to: address, amount: u64) acquires ManagedFungibleAsset {
        let from_addr = signer::address_of(from);
        let asset = get_metadata();
        let transfer_ref = &authorized_borrow_refs_without_owner(asset).transfer_ref;
        let from_wallet = primary_fungible_store::primary_store(from_addr, asset);
        let to_wallet = primary_fungible_store::ensure_primary_store_exists(to, asset);
        fungible_asset::transfer_with_ref(transfer_ref, from_wallet, to_wallet, amount);
    }

     public entry fun SpendOnMerchant(from: &signer, to: address, amount: u64) acquires ManagedFungibleAsset {
        let from_addr = signer::address_of(from);
        let asset = get_metadata();
        let transfer_ref = &authorized_borrow_refs_without_owner(asset).transfer_ref;
        let from_wallet = primary_fungible_store::primary_store(from_addr, asset);
        let to_wallet = primary_fungible_store::ensure_primary_store_exists(to, asset);
        fungible_asset::transfer_with_ref(transfer_ref, from_wallet, to_wallet, amount);
    }

    public entry fun transfer(admin: &signer, from: address, to: address, amount: u64) acquires ManagedFungibleAsset {
        let asset = get_metadata();
        let transfer_ref = &authorized_borrow_refs(admin, asset).transfer_ref;
        let from_wallet = primary_fungible_store::primary_store(from, asset);
        let to_wallet = primary_fungible_store::ensure_primary_store_exists(to, asset);
        fungible_asset::transfer_with_ref(transfer_ref, from_wallet, to_wallet, amount);
    }

    public entry fun burn(admin: &signer, from: address, amount: u64) acquires ManagedFungibleAsset {
        let asset = get_metadata();
        let burn_ref = &authorized_borrow_refs(admin, asset).burn_ref;
        let from_wallet = primary_fungible_store::primary_store(from, asset);
        fungible_asset::burn_from(burn_ref, from_wallet, amount);
    }

    public fun withdraw(admin: &signer, amount: u64, from: address): FungibleAsset acquires ManagedFungibleAsset {
        let asset = get_metadata();
        let transfer_ref = &authorized_borrow_refs(admin, asset).transfer_ref;
        let from_wallet = primary_fungible_store::primary_store(from, asset);
        fungible_asset::withdraw_with_ref(transfer_ref, from_wallet, amount)
    }

    public fun deposit(admin: &signer, to: address, fa: FungibleAsset) acquires ManagedFungibleAsset {
        let asset = get_metadata();
        let transfer_ref = &authorized_borrow_refs(admin, asset).transfer_ref;
        let to_wallet = primary_fungible_store::ensure_primary_store_exists(to, asset);
        fungible_asset::deposit_with_ref(transfer_ref, to_wallet, fa);
    }

     /// Set the pending admin to the specified new admin. The new admin still needs to accept to become the admin.
    public entry fun transfer_admin(admin: &signer, new_admin: address) acquires Management {
        assert_is_admin(admin);
        assert!(signer::address_of(admin) != new_admin, ESAME_ADMIN);
        let management = borrow_global_mut<Management>(usdt_address());
        management.pending_admin = new_admin;
        event::emit(TransferAdmin {
            admin: management.admin,
            pending_admin: new_admin,
        });
    }

    /// Accept the admin role. This can only be called by the pending admin.
    public entry fun accept_admin(pending_admin: &signer) acquires Management {
        let management = borrow_global_mut<Management>(usdt_address());
        assert!(signer::address_of(pending_admin) == management.pending_admin, EUNAUTHORIZED);
        let old_admin = management.admin;
        management.admin = management.pending_admin;
        management.pending_admin = @0x0;
        event::emit(AcceptAdmin {
            old_admin,
            new_admin: management.admin,
        });
    }

    inline fun authorized_borrow_refs(
        owner: &signer,
        asset: Object<Metadata>,
    ): &ManagedFungibleAsset acquires ManagedFungibleAsset {
        assert!(object::is_owner(asset, signer::address_of(owner)), error::permission_denied(ENOT_OWNER));
        borrow_global<ManagedFungibleAsset>(object::object_address(&asset))
    }

     inline fun authorized_borrow_refs_without_owner(
        asset: Object<Metadata>,
    ): &ManagedFungibleAsset acquires ManagedFungibleAsset {
        assert!(object::is_owner(asset, @PhotonDevAddress), error::permission_denied(ENOT_OWNER));
        borrow_global<ManagedFungibleAsset>(object::object_address(&asset))
    }

    #[test(creator = @PhotonDevAddress)]
    fun test_basic_flow(
        creator: &signer,
    ) acquires ManagedFungibleAsset {
        init_module(creator);
        let creator_address = signer::address_of(creator);
        let aaron_address = @0xface;

        mint(creator, creator_address, 100);
        let asset = get_metadata();
        assert!(primary_fungible_store::balance(creator_address, asset) == 100, 4);
        freeze_account(creator, creator_address);
        assert!(primary_fungible_store::is_frozen(creator_address, asset), 5);
        transfer(creator, creator_address, aaron_address, 10);
        assert!(primary_fungible_store::balance(aaron_address, asset) == 10, 6);

        unfreeze_account(creator, creator_address);
        assert!(!primary_fungible_store::is_frozen(creator_address, asset), 7);
        burn(creator, creator_address, 90);
    }

    #[test(creator = @PhotonDevAddress, aaron = @0xface)]
    #[expected_failure(abort_code = 0x50001, location = Self)]
    fun test_permission_denied(
        creator: &signer,
        aaron: &signer
    ) acquires ManagedFungibleAsset {
        init_module(creator);
        let creator_address = signer::address_of(creator);
        mint(aaron, creator_address, 100);
    }
}