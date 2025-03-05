module loterry_sc::jackpot {
    use std::signer;
    use std::vector;
    use aptos_framework::event::emit;
    use aptos_framework::randomness;
    use loterry_sc::luckey_wheel_ticket;

    /// Not authorized to perform this action
    const ENOT_AUTHORIZED: u64 = 0;
    /// Not enough to spin
    const ENOT_ENOUGH_SPIN: u64 = 1;

    struct JackPotConfig has store, key {
        operator: address,
        jackpot_num: u64,
        jackpot_range: u64,
    }

    #[event]
    struct SpinEvent has drop, store {
        user: address,
        spin_time: u64,
        jackpot_number: u64,
        spins: vector<u64>,
    }

    public entry fun init(operator: &signer) {
        move_to(operator, JackPotConfig {
            operator: signer::address_of(operator),
            jackpot_num: 6666,
            jackpot_range: 999999
        });
    }

    public entry fun set_operator(operator: &signer, new_operator: address) acquires JackPotConfig {
        let config = get_jackpot_config();
        assert!(
            signer::address_of(operator) == config.operator || signer::address_of(operator) == @deployer,
            ENOT_AUTHORIZED
        );
        config.operator = new_operator;
    }

    public entry fun set_jackpot_range(operator: &signer, new_range: u64) acquires JackPotConfig {
        let config = get_jackpot_config();
        assert!(
            signer::address_of(operator) == config.operator || signer::address_of(operator) == @deployer,
            ENOT_AUTHORIZED
        );
        config.jackpot_range = new_range;
    }

    #[randomness]
    entry fun random_new_jackpot(operator: &signer) acquires JackPotConfig {
        let config = get_jackpot_config();
        assert!(
            signer::address_of(operator) == config.operator || signer::address_of(operator) == @deployer,
            ENOT_AUTHORIZED
        );
        let new_jackpot = randomness::u64_range(0, config.jackpot_range);
        config.jackpot_num = new_jackpot;
    }

    #[randomness]
    entry fun spin(user: &signer, spinAmout: u64) acquires JackPotConfig {
        let user_address = signer::address_of(user);
        let config = get_jackpot_config();
        let user_spins_amount = luckey_wheel_ticket::get_user_spins_amount(user_address);
        assert!(user_spins_amount >= spinAmout, ENOT_ENOUGH_SPIN);
        let spined = &mut 0;
        let random_vec = vector[];
        while (*spined < spinAmout) {
            let random = randomness::u64_range(0, config.jackpot_range);
            vector::push_back(&mut random_vec, random);
            *spined = *spined + 1;
        };
        luckey_wheel_ticket::user_spined_tickets(user_address, *spined);
        emit(SpinEvent {
            user: user_address,
            spin_time: *spined,
            spins: random_vec,
            jackpot_number: config.jackpot_num,
        })
    }

    #[view]
    public fun get_jackpot_num(): u64 acquires JackPotConfig {
        get_jackpot_config().jackpot_num
    }

    inline fun get_jackpot_config(): &mut JackPotConfig {
        borrow_global_mut<JackPotConfig>(@deployer)
    }

    #[test_only]
    public fun test_spin(user: &signer, spinAmout: u64) acquires JackPotConfig {
        spin(user, spinAmout);
    }
}