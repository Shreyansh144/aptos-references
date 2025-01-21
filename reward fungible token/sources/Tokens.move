module swap_account::Tokens{
    use aptos_framework::coin::{MintCapability, BurnCapability};
    use aptos_framework::coin;
    use std::string;
    use std::signer;
    // use swap_account::SimplpSwap::{generate_lp_name_symbol, create_pool, pair_exist, add_liquiduty, LP, get_coin, remove_liquidity, swap_x_to_y, get_amount_out};
    // use aptos_framework::account::create_account_for_test;
    // use swap_account::Math::sqrt;
    // use std::option;

    struct ETH {}
    struct USDT {}
    struct USDC {}
    struct BTC {}

    struct Caps<phantom CoinType> has key {
        mint:MintCapability<CoinType>,
        burn:BurnCapability<CoinType>
    }

    public fun initialize_register_of_tokens(sender:&signer){
        assert!(signer::address_of(sender) == @swap_account, 0);
        let (burn_eth,freeze_eth,mint_eth) = coin::initialize<ETH>(
            sender,
            string::utf8(b"eth token"),
            string::utf8(b"ETH"),
            7,
            true
        );

        let (burn_usdt,freeze_usdt,mint_usdt) = coin::initialize<USDT>(
            sender,
            string::utf8(b"usdt token"),
            string::utf8(b"USDT"),
            6,
            true
        );

        let (burn_usdc,freeze_usdc,mint_usdc) = coin::initialize<USDC>(
            sender,
            string::utf8(b"usdc token"),
            string::utf8(b"USDC"),
            6,
            true
        );

        let (burn_btc,freeze_btc,mint_btc) = coin::initialize<BTC>(
            sender,
            string::utf8(b"btc token"),
            string::utf8(b"BTC"),
            8,
            true
        );

        coin::destroy_freeze_cap(freeze_eth);
        coin::destroy_freeze_cap(freeze_usdt);
        coin::destroy_freeze_cap(freeze_usdc);
        coin::destroy_freeze_cap(freeze_btc);

          move_to(sender,Caps<ETH>{
            mint:mint_eth,
            burn:burn_eth
        });
        move_to(sender,Caps<USDT>{
            mint:mint_usdt,
            burn:burn_usdt
        });
        move_to(sender,Caps<USDC>{
            mint:mint_usdc,
            burn:burn_usdc
        });
        move_to(sender,Caps<BTC>{
            mint:mint_btc,
            burn:burn_btc
        });

        // coin::register<ETH>(sender);
        // coin::register<USDT>(sender);
        // coin::register<USDC>(sender);
        // coin::register<BTC>(sender);

        // let caps = borrow_global<Caps<ETH>>(signer::address_of(sender));
        // let eth = coin::mint(1000000000,&caps.mint);//100 eth
        // coin::deposit(signer::address_of(sender),eth);

        // let caps = borrow_global<Caps<USDT>>(signer::address_of(sender));
        // let usdt = coin::mint(1000000000,&caps.mint);//1000 usdt
        // coin::deposit(signer::address_of(sender),usdt);

        // let caps = borrow_global<Caps<USDC>>(signer::address_of(sender));
        // let usdc = coin::mint(1000000000,&caps.mint);//1000 usdc
        // coin::deposit(signer::address_of(sender),usdc);

        // let caps = borrow_global<Caps<BTC>>(signer::address_of(sender));
        // let btc = coin::mint(1000000000,&caps.mint);//10 btc
        // coin::deposit(signer::address_of(sender),btc);

        // create_pool<ETH,USDT>(sender);
        // create_pool<USDT,USDC>(sender);
        // create_pool<USDC,BTC>(sender);
        // create_pool<BTC,ETH>(sender);
        // create_pool<ETH,USDC>(sender);
        // create_pool<USDT,BTC>(sender);

        // add_liquiduty<ETH,USDT>(sender,100000000,100000000);
        // add_liquiduty<USDT,USDC>(sender,100000000,100000000);
        // add_liquiduty<USDC,BTC>(sender,100000000,100000000);
        // add_liquiduty<BTC,ETH>(sender,100000000,100000000);
        // add_liquiduty<ETH,USDC>(sender,100000000,100000000);
        // add_liquiduty<USDT,BTC>(sender,100000000,100000000);

        // swap_x_to_y<ETH,USDT>(sender,1000000);
        // swap_x_to_y<USDT,USDC>(sender,1000000);
        // swap_x_to_y<USDC,BTC>(sender,1000000);
        // swap_x_to_y<BTC,ETH>(sender,1000000);
        // swap_x_to_y<ETH,USDC>(sender,1000000);
        // swap_x_to_y<USDT,BTC>(sender,1000000);
    }

    public fun mint_eth_coin(sender:&signer) acquires Caps {
        coin::register<ETH>(sender);

        let caps = borrow_global<Caps<ETH>>(@swap_account);
        let eth = coin::mint(1000000,&caps.mint);//0.1 eth
        coin::deposit(signer::address_of(sender),eth);

    }

    public fun mint_usdc_coin(sender:&signer) acquires Caps {
        coin::register<USDC>(sender);

        let caps = borrow_global<Caps<USDC>>(@swap_account);
        let usdc = coin::mint(10000000,&caps.mint);//10 usdc
        coin::deposit(signer::address_of(sender),usdc);
    }

    public fun mint_usdt_coin(sender:&signer) acquires Caps {
        coin::register<USDT>(sender);

        let caps = borrow_global<Caps<USDT>>(@swap_account);
        let usdt = coin::mint(10000000,&caps.mint);//10 usdt
        coin::deposit(signer::address_of(sender),usdt);
    }

    public fun mint_btc_coin(sender:&signer) acquires Caps {
        coin::register<BTC>(sender);

        let caps = borrow_global<Caps<BTC>>(@swap_account);
        let btc = coin::mint(1000000,&caps.mint);//0.01 btc
        coin::deposit(signer::address_of(sender),btc);
    }



}