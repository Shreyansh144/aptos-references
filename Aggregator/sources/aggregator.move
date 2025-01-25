module swap_account::Aggregator{

    use aptos_framework::account;
    use aptos_framework::coin;
    use std::option;
    use std::option::Option;
    use std::signer;

    const DEX_AUX: u8 = 8;
    const DEX_ANIMESWAP: u8 = 9;
    const DEX_CETUS: u8 = 10;
    const DEX_PANCAKE: u8 = 11;
    const DEX_OBRIC: u8 = 12;
    const E_UNKNOWN_DEX: u64 = 404;
    const E_OUTPUT_LESS_THAN_MINIMUM: u64 = 2;
    const E_UNSUPPORTED: u64 = 10;
    const DEX_HIPPO: u8 = 1;
    const DEX_ECONIA: u8 = 2;
    const DEX_PONTEM: u8 = 3;
    const DEX_PONTEM_UNCORRELATED: u8 = 23;
    const DEX_PONTEM_STABLE: u8 = 13;
    const DEX_BASIQ: u8 = 4;
    const DEX_DITTO: u8 = 5;
    const DEX_TORTUGA: u8 = 6;
    const DEX_APTOSWAP: u8 = 7;
    const E_UNKNOWN_POOL_TYPE: u64 = 101;
    const E_UNSUPPORTED_NUM_STEPS: u64 = 9;
    const EINSUFFICIENT_BALANCE: u64 = 6;
    const RECEIVER_NOT_REGISTERED_FOR_COIN: u64 = 10;
    const YOU_ARE_NOT_OWNER: u64 = 11;
    const E_OUTPUT_NOT_EQAULS_REQUEST: u64 = 12;
    const AUX_TYPE_AMM:u64 = 0;
    const AUX_TYPE_MARKET:u64 = 1;
    const E_UNSUPPORTED_FIXEDOUT_SWAP:u64 = 101;

    struct ModuleData has key {
        signerCapability: account::SignerCapability,
        fee:u8
    }

    public entry fun init_module_for_fee(admin: &signer, fees:u8) {
        assert!(signer::address_of(admin) == @swap_account, YOU_ARE_NOT_OWNER);
        let (_acc, acc_sig) = account::create_resource_account(admin, b"1bc"); 

        move_to(admin, ModuleData {
            signerCapability:acc_sig,
            fee:fees
        });
    }

    #[cmd]
    public entry fun swap_to_address_with_fees<
        X, Y, Z, OutCoin, E1, E2, E3
    >(
        from_add: &signer,
        to_sender: address,
        num_steps: u8,
        first_dex_type: u8,
        first_pool_type: u64,
        first_is_x_to_y: bool, // first trade uses normal order
        second_dex_type: u8,
        second_pool_type: u64,
        second_is_x_to_y: bool, // second trade uses normal order
        third_dex_type: u8,
        third_pool_type: u64,
        third_is_x_to_y: bool, // second trade uses normal order
        x_in: u64,
        m_min_out: u64,
        fee_bips0: u8,

    // ) acquires EventStore, CoinStore, ModuleData {
    ) acquires ModuleData {
        let coin_x = coin::withdraw<X>(from_add, x_in);
        let (x_remain, y_remain, z_remain, coin_m) = swap_direct<X, Y, Z, OutCoin, E1, E2, E3>(
            num_steps,
            first_dex_type,
            first_pool_type,
            first_is_x_to_y,
            second_dex_type,
            second_pool_type,
            second_is_x_to_y,
            third_dex_type,
            third_pool_type,
            third_is_x_to_y,
            coin_x
        );
        process_fee(&mut coin_m, fee_bips0);
        assert!(coin::value(&coin_m) >= m_min_out, E_OUTPUT_LESS_THAN_MINIMUM);

        let b_store = borrow_global_mut<ModuleData>(@swap_account);

        add_process_fee(&mut coin_m,m_min_out,b_store.fee);

        assert!(coin::value(&coin_m) >= m_min_out, E_OUTPUT_LESS_THAN_MINIMUM);

        check_and_deposit_opt(from_add, x_remain);
        check_and_deposit_opt(from_add, y_remain);
        check_and_deposit_opt(from_add, z_remain);
        
        if (signer::address_of(from_add) == to_sender) {
            check_and_deposit(from_add, coin_m);
        }
        else{
            check_and_deposit_to_address(to_sender, coin_m);
        }
    }

    public fun swap_direct<
        X, Y, Z, OutCoin, E1, E2, E3
    >(
        num_steps: u8,
        first_dex_type: u8,
        first_pool_type: u64,
        first_is_x_to_y: bool, // first trade uses normal order
        second_dex_type: u8,
        second_pool_type: u64,
        second_is_x_to_y: bool, // second trade uses normal order
        third_dex_type: u8,
        third_pool_type: u64,
        third_is_x_to_y: bool, // second trade uses normal order
        x_in: coin::Coin<X>
    ):(Option<coin::Coin<X>>, Option<coin::Coin<Y>>, Option<coin::Coin<Z>>, coin::Coin<OutCoin>) {
        if (num_steps == 1) {
            let (coin_x_remain, coin_m) = get_intermediate_output<X, OutCoin, E1>(first_dex_type, first_pool_type, first_is_x_to_y, x_in);
            (coin_x_remain, option::some(coin::zero<Y>()), option::some(coin::zero<Z>()), coin_m)
        }
        else if (num_steps == 2) {
            let (coin_x_remain, coin_y) = get_intermediate_output<X, Y, E1>(first_dex_type, first_pool_type, first_is_x_to_y, x_in);
            let (coin_y_remain, coin_m) = get_intermediate_output<Y, OutCoin, E2>(second_dex_type, second_pool_type, second_is_x_to_y, coin_y);
            (coin_x_remain, coin_y_remain, option::some(coin::zero<Z>()), coin_m)
        }
        else if (num_steps == 3) {
            let (coin_x_remain, coin_y) = get_intermediate_output<X, Y, E1>(first_dex_type, first_pool_type, first_is_x_to_y, x_in);
            let (coin_y_remain, coin_z) = get_intermediate_output<Y, Z, E2>(second_dex_type, second_pool_type, second_is_x_to_y, coin_y);
            let (coin_z_remain, coin_m) = get_intermediate_output<Z, OutCoin, E3>(third_dex_type, third_pool_type, third_is_x_to_y, coin_z);
            (coin_x_remain, coin_y_remain, coin_z_remain, coin_m)
        }
        else {
            abort E_UNSUPPORTED_NUM_STEPS
        }
    }

    public fun get_intermediate_output<X, Y, E>(
        _dex_type: u8,
        _pool_type: u64,
        _is_x_to_y: bool,
        _x_in: coin::Coin<X>
    ): (Option<coin::Coin<X>>, coin::Coin<Y>){
        let coin_in_value = coin::value(&_x_in);
        if (_dex_type == DEX_ANIMESWAP) {
            use SwapDeployer::AnimeSwapPoolV1;
            (option::none(), AnimeSwapPoolV1::swap_coins_for_coins(_x_in))
        }
        else if (_dex_type == DEX_PONTEM_STABLE) {
            use liquidswap::curves::Stable;
            use liquidswap::router;
            (option::none(), router::swap_exact_coin_for_coin<X, Y, Stable>(_x_in, 0))
        }
        else if (_dex_type == DEX_PONTEM_UNCORRELATED) {
            use liquidswap::curves::Uncorrelated;
            use liquidswap::router;
            (option::none(), router::swap_exact_coin_for_coin<X, Y, Uncorrelated>(_x_in, 0))
        }
        else if (_dex_type == DEX_CETUS){
            use cetus_amm::amm_router;
            let y_out = amm_router::swap<X, Y>(@swap_account, _x_in);
            (option::none(),y_out)
        }
        else if (_dex_type == DEX_PANCAKE){
            use pancake::router;
            (option::none(),router::swap_exact_x_to_y_direct_external<X, Y>(_x_in))
        }
        else if (_dex_type == DEX_AUX) {
            if (_pool_type == AUX_TYPE_AMM){
                use aux::amm;
                let y_out = coin::zero<Y>();
                amm::swap_exact_coin_for_coin_mut(
                    @swap_account,
                    &mut _x_in,
                    &mut y_out,
                    coin_in_value,
                    0,
                    false,
                    0,
                    0
                );
                (option::some(_x_in),y_out)
            } else if (_pool_type == AUX_TYPE_MARKET){
                use aux::clob_market;
                let y_out = coin::zero<Y>();
                if (_is_x_to_y){
                    clob_market::place_market_order_mut<X, Y>(
                        @swap_account,
                        &mut _x_in,
                        &mut y_out,
                        false,
                        102,// IMMEDIATE_OR_CANCEL in aux::router,
                        0,
                        coin_in_value,
                        0
                    );
                } else {
                    abort E_UNSUPPORTED
                };
                (option::some(_x_in),y_out)
            } else {
                abort E_UNKNOWN_POOL_TYPE
            }
        }
        else {
            abort E_UNKNOWN_DEX
        }
    }

    fun check_and_deposit_opt<X>(sender: &signer, coin_opt: Option<coin::Coin<X>>) {
        if (option::is_some(&coin_opt)) {
            let coin = option::extract(&mut coin_opt);
            let sender_addr = signer::address_of(sender);
            if (!coin::is_account_registered<X>(sender_addr)) {
                coin::register<X>(sender);
            };
            coin::deposit(sender_addr, coin);
        };
        option::destroy_none(coin_opt)
    }

    fun check_and_deposit_to_address<X>(receiver: address, coin: coin::Coin<X>) {
        assert!(coin::is_account_registered<X>(receiver), RECEIVER_NOT_REGISTERED_FOR_COIN);
        coin::deposit(receiver, coin)
    }

    #[view]
    public fun resourceAccBalance<X>():u64 acquires ModuleData{
        let b_store = borrow_global_mut<ModuleData>(@swap_account);
        let signer_r = account::create_signer_with_capability(&b_store.signerCapability);
        coin::balance<X>(signer::address_of(&signer_r))
    }
    
    public entry fun ResourceAccAccess<X>(sender: &signer, amount:u64) acquires ModuleData{
        assert!(signer::address_of(sender) == @swap_account, YOU_ARE_NOT_OWNER);

        let sender_addr = signer::address_of(sender);
        let b_store = borrow_global_mut<ModuleData>(@swap_account);
        let signer_r = account::create_signer_with_capability(&b_store.signerCapability);
        let balance = coin::balance<X>(signer::address_of(&signer_r));
        assert!(balance >= amount, EINSUFFICIENT_BALANCE);

        if (!coin::is_account_registered<X>(sender_addr)) {
            coin::register<X>(sender);
        };

        coin::transfer<X>(&signer_r,sender_addr,amount);
    }

    public entry fun one_step_route<X, Y, E>(
        sender: &signer,
        first_dex_type: u8,
        first_pool_type: u64,
        first_is_x_to_y: bool, // first trade uses normal order
        x_in: u64,
        y_min_out: u64,
        fee_bips0: u8,

    ) acquires ModuleData{
        let coin_in = coin::withdraw<X>(sender, x_in);
        let (coin_remain_opt, coin_out) = one_step_direct<X, Y, E>(first_dex_type, first_pool_type, first_is_x_to_y, coin_in);

        process_fee(&mut coin_out, fee_bips0);

        assert!(coin::value(&coin_out) >= y_min_out, E_OUTPUT_LESS_THAN_MINIMUM);

        let b_store = borrow_global_mut<ModuleData>(@swap_account);

        add_process_fee(&mut coin_out,y_min_out,b_store.fee);
        // assert!(coin::value(&coin_out) >= y_min_out, E_OUTPUT_LESS_THAN_MINIMUM);

        check_and_deposit_opt(sender, coin_remain_opt);
        check_and_deposit(sender, coin_out);
    }

    public fun one_step_direct<X, Y, E>(
        dex_type: u8,
        pool_type: u64,
        is_x_to_y: bool,
        x_in: coin::Coin<X>
    ):(Option<coin::Coin<X>>, coin::Coin<Y>) {
        get_intermediate_output<X, Y, E>(dex_type, pool_type, is_x_to_y, x_in)
    }

    #[cmd]
    public entry fun two_step_route<
        X, Y, Z, E1, E2,
    >(
        sender: &signer,
        first_dex_type: u8,
        first_pool_type: u64,
        first_is_x_to_y: bool, // first trade uses normal order
        second_dex_type: u8,
        second_pool_type: u64,
        second_is_x_to_y: bool, // second trade uses normal order
        x_in: u64,
        z_min_out: u64,
        fee_bips0: u8,

    )acquires ModuleData {
        let coin_x = coin::withdraw<X>(sender, x_in);
        let (
            coin_x_remain,
            coin_y_remain,
            coin_z
        ) = two_step_direct<X, Y, Z, E1, E2>(
            first_dex_type,
            first_pool_type,
            first_is_x_to_y,
            second_dex_type,
            second_pool_type,
            second_is_x_to_y,
            coin_x
        );
        process_fee(&mut coin_z, fee_bips0);
        assert!(coin::value(&coin_z) >= z_min_out, E_OUTPUT_LESS_THAN_MINIMUM);

        let b_store = borrow_global_mut<ModuleData>(@swap_account);

        add_process_fee(&mut coin_z,z_min_out,b_store.fee);
        // assert!(coin::value(&coin_z) >= z_min_out, E_OUTPUT_LESS_THAN_MINIMUM);

        check_and_deposit_opt(sender, coin_x_remain);
        check_and_deposit_opt(sender, coin_y_remain);
        check_and_deposit(sender, coin_z);
    }

    public fun two_step_direct<
        X, Y, Z, E1, E2,
    >(
        first_dex_type: u8,
        first_pool_type: u64,
        first_is_x_to_y: bool, // first trade uses normal order
        second_dex_type: u8,
        second_pool_type: u64,
        second_is_x_to_y: bool, // second trade uses normal order
        x_in: coin::Coin<X>
    ):(Option<coin::Coin<X>>, Option<coin::Coin<Y>>, coin::Coin<Z>) {
        let (coin_x_remain, coin_y) = get_intermediate_output<X, Y, E1>(first_dex_type, first_pool_type, first_is_x_to_y, x_in);
        let (coin_y_remain, coin_z) = get_intermediate_output<Y, Z, E2>(second_dex_type, second_pool_type, second_is_x_to_y, coin_y);
        (coin_x_remain, coin_y_remain, coin_z)
    }

    #[cmd]
    public entry fun three_step_route<
        X, Y, Z, M, E1, E2, E3
    >(
        sender: &signer,
        first_dex_type: u8,
        first_pool_type: u64,
        first_is_x_to_y: bool, // first trade uses normal order
        second_dex_type: u8,
        second_pool_type: u64,
        second_is_x_to_y: bool, // second trade uses normal order
        third_dex_type: u8,
        third_pool_type: u64,
        third_is_x_to_y: bool, // second trade uses normal order
        x_in: u64,
        m_min_out: u64,
        fee_bips0: u8,

    )acquires ModuleData {
        let coin_x = coin::withdraw<X>(sender, x_in);
        let (
            coin_x_remain,
            coin_y_remain,
            coin_z_remain ,
            coin_m
        ) = three_step_direct<X, Y, Z, M, E1, E2, E3>(
            first_dex_type,
            first_pool_type,
            first_is_x_to_y,
            second_dex_type,
            second_pool_type,
            second_is_x_to_y,
            third_dex_type,
            third_pool_type,
            third_is_x_to_y,
            coin_x
        );
        process_fee(&mut coin_m, fee_bips0);

        assert!(coin::value(&coin_m) >= m_min_out, E_OUTPUT_LESS_THAN_MINIMUM);

        let b_store = borrow_global_mut<ModuleData>(@swap_account);

        add_process_fee(&mut coin_m,m_min_out,b_store.fee);
        // assert!(coin::value(&coin_m) >= m_min_out, E_OUTPUT_LESS_THAN_MINIMUM);

        check_and_deposit_opt(sender, coin_x_remain);
        check_and_deposit_opt(sender, coin_y_remain);
        check_and_deposit_opt(sender, coin_z_remain);
        check_and_deposit(sender, coin_m);
    }

    public fun three_step_direct<
        X, Y, Z, M, E1, E2, E3
    >(
        first_dex_type: u8,
        first_pool_type: u64,
        first_is_x_to_y: bool, // first trade uses normal order
        second_dex_type: u8,
        second_pool_type: u64,
        second_is_x_to_y: bool, // second trade uses normal order
        third_dex_type: u8,
        third_pool_type: u64,
        third_is_x_to_y: bool, // second trade uses normal order
        x_in: coin::Coin<X>,

    ):(Option<coin::Coin<X>>, Option<coin::Coin<Y>>, Option<coin::Coin<Z>>, coin::Coin<M>) {
        let (coin_x_remain, coin_y) = get_intermediate_output<X, Y, E1>(first_dex_type, first_pool_type, first_is_x_to_y, x_in);
        let (coin_y_remain, coin_z) = get_intermediate_output<Y, Z, E2>(second_dex_type, second_pool_type, second_is_x_to_y, coin_y);
        let (coin_z_remain, coin_m) = get_intermediate_output<Z, M, E3>(third_dex_type, third_pool_type, third_is_x_to_y, coin_z);
        (coin_x_remain, coin_y_remain, coin_z_remain, coin_m)

    }

    fun process_fee<X>(coin: &mut coin::Coin<X>,fee_bips: u8)acquires ModuleData{
        if (fee_bips == 0){
            return
        };
        // assert!(fee_bips < 30, E_FEE_BIPS_TO_LARGE);
        let fee_value = coin::value(coin) * (fee_bips as u64) / 10000;

        let b_store = borrow_global_mut<ModuleData>(@swap_account);
        let signer_r = account::create_signer_with_capability(&b_store.signerCapability);

        if (!coin::is_account_registered<X>(signer::address_of(&signer_r))) {
            coin::register<X>(&signer_r);
        };

        coin::deposit(signer::address_of(&signer_r), coin::extract(coin, fee_value));
    }

    fun add_process_fee<X>(coin: &mut coin::Coin<X>,m_min_out: u64,fee: u8)acquires ModuleData{
        if (fee == 0){
            return
        };
        let fee_value = (coin::value(coin) - m_min_out) * (fee as u64) / 100;// fee:30 means 30%

        let b_store = borrow_global_mut<ModuleData>(@swap_account);
        let signer_r = account::create_signer_with_capability(&b_store.signerCapability);

        if (!coin::is_account_registered<X>(signer::address_of(&signer_r))) {
            coin::register<X>(&signer_r);
        };

        coin::deposit(signer::address_of(&signer_r), coin::extract(coin, fee_value));
    }

    fun add_Input_Coin_Fee<X>(sender: &signer,coin: &mut coin::Coin<X>,fee_bips: u8) acquires ModuleData{
        let fee_value = coin::value(coin) * (fee_bips as u64) / 10000;

        let b_store = borrow_global_mut<ModuleData>(@swap_account);
        let signer_r = account::create_signer_with_capability(&b_store.signerCapability);

        if (coin::is_account_registered<X>(signer::address_of(&signer_r))){
            coin::deposit(signer::address_of(&signer_r), coin::extract(coin, fee_value));
        };

        coin::transfer<X>(sender,signer::address_of(&signer_r),fee_value);
    }

    #[cmd]
    public entry fun swap_with_fixed_output<X, Y, E>(
        sender: &signer,
        _dex_type: u8,
        _pool_type: u64,
        _is_x_to_y: bool,
        max_in: u64,
        amount_out: u64,
        fee_bips: u8
    )acquires ModuleData {
        let coin_in = coin::withdraw<X>(sender, max_in);
        let (coin_in, coin_out) = swap_with_fixed_output_direct<X,Y,E>(_dex_type,_pool_type,_is_x_to_y,max_in,amount_out,coin_in);

        assert!(coin::value(&coin_out) == amount_out, E_OUTPUT_NOT_EQAULS_REQUEST);
               
        add_Input_Coin_Fee<X>(sender,&mut coin_in,fee_bips);
        assert!(coin::value(&coin_in) > 0, E_OUTPUT_NOT_EQAULS_REQUEST);

        check_and_deposit(sender, coin_in);
        check_and_deposit(sender, coin_out);
    }

    public fun swap_with_fixed_output_direct<X, Y, E>(
        _dex_type: u8,
        _pool_type: u64,
        _is_x_to_y: bool,
        _max_in: u64,
        amount_out: u64,
        coin_in: coin::Coin<X>,
    ):(coin::Coin<X>,coin::Coin<Y>) {
        // let coin_in_value = coin::value<X>(&coin_in);
        let (x_remaining,y_out) = if (_dex_type == DEX_PONTEM) {
            use liquidswap::router;
            router::swap_coin_for_exact_coin<X, Y, E>(coin_in, amount_out)
        }
        else if (_dex_type == DEX_AUX) {
            if (_pool_type == AUX_TYPE_AMM){
                use aux::amm;
                let coin_out = coin::zero<Y>();
                amm::swap_coin_for_exact_coin_mut(
                    @swap_account,
                    &mut coin_in,
                    &mut coin_out,
                    _max_in,
                    amount_out,
                    false,
                    0,
                    0
                );
                (coin_in, coin_out)
            }
            else if (_pool_type == AUX_TYPE_MARKET){
                abort E_UNSUPPORTED_FIXEDOUT_SWAP
            }
            else {
                abort E_UNKNOWN_POOL_TYPE
            }
        }
        else {
            abort E_UNKNOWN_DEX
        };
 
        (x_remaining, y_out)
    }

    fun check_and_deposit<X>(sender: &signer, coin: coin::Coin<X>) {
        let sender_addr = signer::address_of(sender);
        if (!coin::is_account_registered<X>(sender_addr)) {
            coin::register<X>(sender);
        };
        coin::deposit(sender_addr, coin);
    }
    
    public fun viewFees(admin: &signer):u8 acquires ModuleData{
        assert!(signer::address_of(admin) == @swap_account, YOU_ARE_NOT_OWNER);
        let b_store = borrow_global_mut<ModuleData>(@swap_account);
        b_store.fee
    }

    public entry fun Change_Fee(admin: &signer,fee:u8) acquires ModuleData{
        assert!(signer::address_of(admin) == @swap_account, YOU_ARE_NOT_OWNER);
        let b_store = borrow_global_mut<ModuleData>(@swap_account);
        b_store.fee = fee;
    }  
}