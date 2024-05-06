abstract class BankAccount {
  String _accountNumber;
  String _ownerName;
  double _balance;

  BankAccount(this._accountNumber, this._ownerName, this._balance);

  String get accountNumber => _accountNumber;
  String get ownerName => _ownerName;
  double get balance => _balance;

  set ownerName(String name) {
    _ownerName = name;
  }

  void deposit(double amount) {
    _balance += amount;
  }

  bool withdraw(double amount) {
    if (_balance >= amount) {
      _balance -= amount;
      return true;
    }
    return false;
  }

  void displayBalance() {
    print('Current balance: \$$_balance');
  }
}

class SavingsAccount extends BankAccount {
  double _interestRate;

  SavingsAccount(String accountNumber, String ownerName, double balance,
      this._interestRate)
      : super(accountNumber, ownerName, balance);

  double get interestRate => _interestRate;

  void applyInterest() {
    deposit(balance * _interestRate);
  }
}

class CheckingAccount extends BankAccount {
  double _transactionFee;
  double _minBalance;

  CheckingAccount(String accountNumber, String ownerName, double balance,
      this._transactionFee, this._minBalance)
      : super(accountNumber, ownerName, balance);

  double get transactionFee => _transactionFee;
  double get minBalance => _minBalance;

  @override
  bool withdraw(double amount) {
    if (_balance - amount - _transactionFee >= _minBalance) {
      _balance -= (amount + _transactionFee);
      return true;
    }
    return false;
  }

  void assessPenalty() {
    if (_balance < _minBalance) {
      _balance -= 10;
    }
  }
}

class Transaction {
  String type;
  double amount;
  String accountNumber;

  Transaction(this.type, this.amount, this.accountNumber);
}

class TransactionProcessor {
  final Stream<Transaction> _transactionStream;
  final Map<String, BankAccount> _accounts;

  TransactionProcessor(this._transactionStream, this._accounts) {
    _transactionStream.listen((transaction) {
      if (_accounts.containsKey(transaction.accountNumber)) {
        final account = _accounts[transaction.accountNumber];
        if (account != null) {
          switch (transaction.type) {
            case 'deposit':
              account.deposit(transaction.amount);
              break;
            case 'withdraw':
              account.withdraw(transaction.amount);
              break;
            default:
              print('Invalid transaction type');
          }
        } else {
          print('Account is null');
        }
      } else {
        print('Account not found');
      }
    });
  }
}

void main() {
  var savingsAccount = SavingsAccount('SA123', 'John Doe', 1000, 0.05);
  var checkingAccount = CheckingAccount('CA456', 'Jane Smith', 1500, 2, 500);

  var accounts = {'SA123': savingsAccount, 'CA456': checkingAccount};

  var transactions = Stream<Transaction>.fromIterable([
    Transaction('deposit', 200, 'SA123'),
    Transaction('withdraw', 100, 'CA456'),
    Transaction('deposit', 500, 'SA789'),
  ]);

  var processor = TransactionProcessor(transactions, accounts);
}
