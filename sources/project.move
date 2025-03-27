module MyModule::StudentLoan {

    use aptos_framework::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;

    /// Struct representing a student loan.
    struct Loan has store, key {
        amount: u64,       // Total loan amount
        paid_amount: u64,  // Amount that has been paid back
    }

    /// Function to create a new loan for a student.
    public fun create_loan(student: &signer, amount: u64) {
        let loan = Loan {
            amount,
            paid_amount: 0,
        };
        move_to(student, loan);
    }

    /// Function for a student to repay part of their loan.
    public fun repay_loan(payer: &signer, student_address: address, amount: u64) acquires Loan {
        let loan = borrow_global_mut<Loan>(student_address);

        // Ensure the amount being paid is not more than the remaining loan balance.
        assert!(loan.amount > loan.paid_amount, 1);  // 1 indicates error, meaning loan not fully repaid yet.
        let remaining_balance = loan.amount - loan.paid_amount;
        assert!(amount <= remaining_balance, 2);  // 2 indicates error, repaying more than the loan balance.

        // Transfer the repayment amount from the payer to the student's loan account.
        let payment = coin::withdraw<AptosCoin>(payer, amount);
        coin::deposit<AptosCoin>(student_address, payment);

        // Update the paid amount of the loan.
        loan.paid_amount = loan.paid_amount + amount;
    }
}
