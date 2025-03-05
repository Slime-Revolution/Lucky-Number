module loterry_sc::luckey_wheel_ticket {
    use std::signer;
    use std::vector;
    use aptos_std::smart_table;
    use aptos_std::smart_table::SmartTable;

    friend loterry_sc::jackpot;
    /// Not authorized to perform this action
    const ENOT_AUTHORIZED: u64 = 0;
    /// Not enough to spin
    const ENOT_ENOUGH_SPIN: u64 = 1;
    /// Not enough to prize
    const ENOT_ENOUGH_PRIZE: u64 = 2;

    const MAX_SPIN:u64 = 800_000;
    const ONE_AM_APT:u64 = 1_00_000_000;

    struct JackPotConfig has store, key {
        operator: address,
        user_spins: SmartTable<address, u64>,
    }

    #[event]
    struct SpinEvent has drop, store {
        user: address,
        spin_amount: u64,
        prize: vector<u64>,
    }

    #[event]
    struct JackpotEvent has drop, store {
        user: address,
        jackpot_amount: u64,
    }

    public entry fun init(operator: &signer) {
        move_to(operator, JackPotConfig {
            operator: signer::address_of(operator),
            user_spins: smart_table::new(),
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

    public entry fun add_user_spins(operator: &signer, users: vector<address>, spins: vector<u64>) acquires JackPotConfig {
        let config = get_jackpot_config();
        assert!( signer::address_of(operator) == config.operator, ENOT_AUTHORIZED);
        vector::zip(users, spins, |user, spin| {
            let user_spins = get_user_spins_with_config(user, config);
            smart_table::upsert(&mut config.user_spins, user, *user_spins + spin);
        });
    }

    public entry fun add_user_spins_force(operator: &signer, users: vector<address>, spins: vector<u64>) acquires JackPotConfig {
        let config = get_jackpot_config();
        assert!( signer::address_of(operator) == config.operator, ENOT_AUTHORIZED);
        vector::zip(users, spins, |user, spin| {
            smart_table::upsert(&mut config.user_spins, user, spin);
        });
    }

    public(friend) entry fun user_spined_tickets(user: address, spined: u64) acquires JackPotConfig {
        let config = get_jackpot_config();
        let user_spin = *smart_table::borrow_mut_with_default(&mut config.user_spins, user, 0);
        assert!(user_spin >= spined, ENOT_ENOUGH_SPIN);
        if (user_spin > 0) {
            smart_table::upsert(&mut config.user_spins, user, user_spin - spined);
        }
    }

    #[view]
    public fun get_user_spins_amount(user: address): u64 acquires JackPotConfig {
        let config = get_jackpot_config();
        *smart_table::borrow_mut_with_default(&mut config.user_spins, user, 0)
    }

    inline fun get_user_spins_with_config(user: address, config: &mut JackPotConfig): &mut u64 {
        smart_table::borrow_mut_with_default(&mut config.user_spins, user, 0)
    }

    inline fun get_jackpot_config(): &mut JackPotConfig {
        borrow_global_mut<JackPotConfig>(@deployer)
    }
}