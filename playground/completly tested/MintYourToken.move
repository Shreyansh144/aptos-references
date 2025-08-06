module swap_account::TestCoinsV2 {
    use std::signer;
    use std::string::utf8;

    use aptos_framework::coin::{Self, MintCapability, FreezeCapability, BurnCapability};
    // use swap_account::SimplpSwap::{add_liquidity, create_pool};

    struct UST {}

    struct NB {}

    struct BTC {}

    struct ETH {}


    struct Caps<phantom CoinType> has key {
        mint: MintCapability<CoinType>,
        freeze: FreezeCapability<CoinType>,
        burn: BurnCapability<CoinType>,
    }

    public entry fun initialize(admin: &signer) {
        let (btc_b, btc_f, btc_m) =
            coin::initialize<BTC>(admin,
                utf8(b"Bitcoin"), utf8(b"BTC"), 8, true);
        let (ust_b, ust_f, ust_m) =
            coin::initialize<UST>(admin,
                utf8(b"Tether"), utf8(b"UST"), 8, true);
        let (eth_b, eth_f, eth_m) =
            coin::initialize<ETH>(admin,
                utf8(b"Ether"), utf8(b"ETH"), 8, true);
        let (nb_b, nb_f, nb_m) =
            coin::initialize<NB>(admin,
                utf8(b"NB"), utf8(b"NB"), 8, true);
        move_to(admin, Caps<BTC> { mint: btc_m, freeze: btc_f, burn: btc_b });
        move_to(admin, Caps<UST> { mint: ust_m, freeze: ust_f, burn: ust_b });
        move_to(admin, Caps<ETH> { mint: eth_m, freeze: eth_f, burn: eth_b });
        move_to(admin, Caps<NB> { mint: nb_m, freeze: nb_f, burn: nb_b });
        register_coins_all(admin);
    }

    public entry fun mint_coins_all(admin: &signer)acquires Caps {
        let admin_addr = signer::address_of(admin);
        let caps = borrow_global<Caps<BTC>>(admin_addr);
        let coins = coin::mint<BTC>(100000000000, &caps.mint);//10 btc
        coin::deposit(admin_addr, coins);

        let caps = borrow_global<Caps<UST>>(admin_addr);
        let coins = coin::mint<UST>(100000000000, &caps.mint);//1000 usdt
        coin::deposit(admin_addr, coins);

        let caps = borrow_global<Caps<ETH>>(admin_addr);
        let coins = coin::mint<ETH>(100000000000, &caps.mint);//100 eth
        coin::deposit(admin_addr, coins);

        let caps = borrow_global<Caps<NB>>(admin_addr);
        let coins = coin::mint<NB>(100000000000, &caps.mint);//100 eth
        coin::deposit(admin_addr, coins);
    }

    public entry fun register_coins_all(account: &signer) {
        let account_addr = signer::address_of(account);
        if (!coin::is_account_registered<BTC>(account_addr)) {
            coin::register<BTC>(account);
        };
        if (!coin::is_account_registered<UST>(account_addr)) {
            coin::register<UST>(account);
        };
        if (!coin::is_account_registered<ETH>(account_addr)) {
            coin::register<ETH>(account);
        };
        if (!coin::is_account_registered<NB>(account_addr)) {
            coin::register<NB>(account);
        };
    }
    // only resource_account should call this
    // public entry fun initialize_Liquidity(sender: &signer) {
    //     create_pool<ETH,UST>(sender);
    //     create_pool<BTC,ETH>(sender);
    //     create_pool<UST,BTC>(sender);
    //     create_pool<NB,UST>(sender);

    //     // add_liquidity<ETH,UST>(sender,10000000000,10000000000);
    //     // add_liquidity<BTC,ETH>(sender,10000000000,10000000000);
    //     // add_liquidity<UST,BTC>(sender,10000000000,10000000000);
    //     // add_liquidity<NB,UST>(sender,10000000000,10000000000);
    // }

    // Mints new coin `CoinType` on account `acc_addr`.
    public entry fun mint_coin<CoinType>(admin: &signer, acc_addr: address, amount: u64) acquires Caps {
        let admin_addr = signer::address_of(admin);
        let caps = borrow_global<Caps<CoinType>>(admin_addr);
        let coins = coin::mint<CoinType>(amount, &caps.mint);
        coin::deposit(acc_addr, coins);
    }

    public entry fun mint_eth_coin(sender:&signer) acquires Caps {
        coin::register<ETH>(sender);

        let caps = borrow_global<Caps<ETH>>(@swap_account);
        let eth = coin::mint(100000000,&caps.mint);
        coin::deposit(signer::address_of(sender),eth);
    }

    public entry fun mint_usdt_coin(sender:&signer) acquires Caps {
        coin::register<UST>(sender);

        let caps = borrow_global<Caps<UST>>(@swap_account);
        let usdt = coin::mint(100000000,&caps.mint);
        coin::deposit(signer::address_of(sender),usdt);
    }

    public entry fun mint_btc_coin(sender:&signer) acquires Caps {
        coin::register<BTC>(sender);

        let caps = borrow_global<Caps<BTC>>(@swap_account);
        let btc = coin::mint(100000000,&caps.mint);
        coin::deposit(signer::address_of(sender),btc);
    }

    public entry fun mint_nb_coin(sender:&signer) acquires Caps {
        coin::register<NB>(sender);

        let caps = borrow_global<Caps<NB>>(@swap_account);
        let nb = coin::mint(100000000,&caps.mint);
        coin::deposit(signer::address_of(sender),nb);
    }
}