// ------------------------------
// Base Polymorphic Entity
// ------------------------------
abstract class FinancialEntity {
  String get id;

  String get type;

  String get collectionName;

  /// Used for embeddings
  String toSemanticText();

  /// Firestore / JSON
  Map<String, dynamic> toJson();

  /// Polymorphic factory
  static FinancialEntity fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;

    switch (type) {
      case TransactionEntity.typeKey:
        return TransactionEntity.fromJson(json);
      case AccountEntity.typeKey:
        return AccountEntity.fromJson(json);
      case InvestmentEntity.typeKey:
        return InvestmentEntity.fromJson(json);
      case LoanEntity.typeKey:
        return LoanEntity.fromJson(json);
      case SubscriptionEntity.typeKey: // ✅ new
        return SubscriptionEntity.fromJson(json);
      default:
        throw UnsupportedError('Unknown FinancialEntity type: $type');
    }
  }
}

// ------------------------------
// Transaction
// ------------------------------
class TransactionEntity extends FinancialEntity {
  static const String typeKey = 'transaction';

  @override
  final String id;
  final double amount;
  final String currency;
  final String category;
  final String description;
  final DateTime date;

  // ✅ Extended, optional and practical fields
  final String? accountId;
  final String? loanId; // if EMI or loan-related
  final String? merchant;
  final String?
  mode; // UPI | Card | NEFT | NACH | IMPS | RTGS | AutoPay | AutoDebit
  final String? direction; // credit | debit
  final Map<String, dynamic>? metadata; // extensibility

  TransactionEntity({
    required this.id,
    required this.amount,
    required this.currency,
    required this.category,
    required this.description,
    required this.date,
    this.accountId,
    this.loanId,
    this.merchant,
    this.mode,
    this.direction,
    this.metadata,
  });

  @override
  String get type => typeKey;

  @override
  String get collectionName => 'transactions';

  factory TransactionEntity.fromJson(Map<String, dynamic> json) {
    final dateStr = json['date'] as String?;
    return TransactionEntity(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      category: json['category'] as String,
      description: json['description'] as String,
      date: dateStr != null ? DateTime.parse(dateStr) : DateTime.now(),
      accountId: json['accountId'] as String?,
      loanId: json['loanId'] as String?,
      merchant: json['merchant'] as String?,
      mode: json['mode'] as String?,
      direction: json['direction'] as String?,
      metadata: (json['metadata'] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': typeKey,
    'id': id,
    'amount': amount,
    'currency': currency,
    'category': category,
    'description': description,
    'date': date.toIso8601String(),
    if (accountId != null) 'accountId': accountId,
    if (loanId != null) 'loanId': loanId,
    if (merchant != null) 'merchant': merchant,
    if (mode != null) 'mode': mode,
    if (direction != null) 'direction': direction,
    if (metadata != null) 'metadata': metadata,
  };

  @override
  String toSemanticText() => '''
Transaction:
Amount: $amount $currency
Category: $category
Description: $description
Date: ${date.toIso8601String()}
Merchant: ${merchant ?? '-'}
Mode: ${mode ?? '-'}
Direction: ${direction ?? '-'}
''';
}

// ------------------------------
// Account
// ------------------------------
class AccountEntity extends FinancialEntity {
  static const String typeKey = 'account';

  @override
  final String id;
  final String bankName;
  final String accountType;
  final double balance;

  // ✅ Extended details
  final String? holderName;
  final String? accountNumberMasked;
  final String? ifsc;
  final String? currency; // e.g., INR
  final DateTime? openedDate;

  AccountEntity({
    required this.id,
    required this.bankName,
    required this.accountType,
    required this.balance,
    this.holderName,
    this.accountNumberMasked,
    this.ifsc,
    this.currency,
    this.openedDate,
  });

  @override
  String get type => typeKey;

  @override
  String get collectionName => 'accounts';

  factory AccountEntity.fromJson(Map<String, dynamic> json) {
    final opened = json['openedDate'] as String?;
    return AccountEntity(
      id: json['id'] as String,
      bankName: json['bankName'] as String,
      accountType: json['accountType'] as String,
      balance: (json['balance'] as num).toDouble(),
      holderName: json['holderName'] as String?,
      accountNumberMasked: json['accountNumberMasked'] as String?,
      ifsc: json['ifsc'] as String?,
      currency: json['currency'] as String?,
      openedDate: opened != null ? DateTime.parse(opened) : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': typeKey,
    'id': id,
    'bankName': bankName,
    'accountType': accountType,
    'balance': balance,
    if (holderName != null) 'holderName': holderName,
    if (accountNumberMasked != null) 'accountNumberMasked': accountNumberMasked,
    if (ifsc != null) 'ifsc': ifsc,
    if (currency != null) 'currency': currency,
    if (openedDate != null) 'openedDate': openedDate!.toIso8601String(),
  };

  @override
  String toSemanticText() => '''
Bank Account:
Bank: $bankName
Account Type: $accountType
Current Balance: $balance
Holder: ${holderName ?? '-'}
IFSC: ${ifsc ?? '-'}
''';
}

// ------------------------------
// Investment
// ------------------------------
class InvestmentEntity extends FinancialEntity {
  static const String typeKey = 'investment';

  @override
  final String id;

  /// High-level classification (e.g., Mutual Fund, Stock, PPF, FD, Gold ETF, Index Fund, NPS, REIT)
  final String instrument;

  /// Aggregates (keep existing fields)
  final double investedAmount;
  final double currentValue;

  // ✅ Optional specifics by instrument
  final String? name; // MF scheme name, PPF, FD name, etc.
  final String? platform; // Groww, Kuvera
  final String? symbol; // Stock symbol
  final String? broker; // Zerodha, Angel One

  final int? qty; // For stocks
  final double? avgBuyPrice;

  final double? units; // For ETFs/REITs (can be fractional)
  final double? rate; // For FD interest rate %
  final double? principal; // For FD principal

  final DateTime? maturityDate;

  InvestmentEntity({
    required this.id,
    required this.instrument,
    required this.investedAmount,
    required this.currentValue,
    this.name,
    this.platform,
    this.symbol,
    this.broker,
    this.qty,
    this.avgBuyPrice,
    this.units,
    this.rate,
    this.principal,
    this.maturityDate,
  });

  @override
  String get type => typeKey;

  @override
  String get collectionName => 'investments';

  factory InvestmentEntity.fromJson(Map<String, dynamic> json) {
    final maturity = json['maturityDate'] as String?;
    return InvestmentEntity(
      id: json['id'] as String,
      instrument: json['instrument'] as String,
      investedAmount: (json['investedAmount'] as num).toDouble(),
      currentValue: (json['currentValue'] as num).toDouble(),
      name: json['name'] as String?,
      platform: json['platform'] as String?,
      symbol: json['symbol'] as String?,
      broker: json['broker'] as String?,
      qty: json['qty'] as int?,
      avgBuyPrice: (json['avgBuyPrice'] as num?)?.toDouble(),
      units: (json['units'] as num?)?.toDouble(),
      rate: (json['rate'] as num?)?.toDouble(),
      principal: (json['principal'] as num?)?.toDouble(),
      maturityDate: maturity != null ? DateTime.parse(maturity) : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': typeKey,
    'id': id,
    'instrument': instrument,
    'investedAmount': investedAmount,
    'currentValue': currentValue,
    if (name != null) 'name': name,
    if (platform != null) 'platform': platform,
    if (symbol != null) 'symbol': symbol,
    if (broker != null) 'broker': broker,
    if (qty != null) 'qty': qty,
    if (avgBuyPrice != null) 'avgBuyPrice': avgBuyPrice,
    if (units != null) 'units': units,
    if (rate != null) 'rate': rate,
    if (principal != null) 'principal': principal,
    if (maturityDate != null) 'maturityDate': maturityDate!.toIso8601String(),
  };

  @override
  String toSemanticText() => '''
Investment:
Instrument: $instrument
Name: ${name ?? '-'}
Invested Amount: $investedAmount
Current Value: $currentValue
Symbol: ${symbol ?? '-'} @ ${avgBuyPrice ?? '-'}
Units/Qty: ${units ?? qty ?? '-'}
Platform/Broker: ${platform ?? broker ?? '-'}
Maturity: ${maturityDate?.toIso8601String() ?? '-'}
''';
}

// ------------------------------
// Loan
// ------------------------------
class LoanEntity extends FinancialEntity {
  static const String typeKey = 'loan';

  @override
  final String id;
  final String lender;
  final String loanType; // Home / Personal / Auto / Education
  final double principal;
  final double interestRate; // annual %
  final int tenureMonths;
  final double outstandingAmount;
  final DateTime startDate;

  // ✅ Extended
  final double? emiAmount;
  final DateTime? nextDueDate;
  final String? linkedAccountId; // account used for NACH/AutoDebit

  LoanEntity({
    required this.id,
    required this.lender,
    required this.loanType,
    required this.principal,
    required this.interestRate,
    required this.tenureMonths,
    required this.outstandingAmount,
    required this.startDate,
    this.emiAmount,
    this.nextDueDate,
    this.linkedAccountId,
  });

  @override
  String get type => typeKey;

  @override
  String get collectionName => 'loans';

  factory LoanEntity.fromJson(Map<String, dynamic> json) {
    final start = json['startDate'] as String?;
    final nextDue = json['nextDueDate'] as String?;
    return LoanEntity(
      id: json['id'] as String,
      lender: json['lender'] as String,
      loanType: json['loanType'] as String,
      principal: (json['principal'] as num).toDouble(),
      interestRate: (json['interestRate'] as num).toDouble(),
      tenureMonths: json['tenureMonths'] as int,
      outstandingAmount: (json['outstandingAmount'] as num).toDouble(),
      startDate: start != null ? DateTime.parse(start) : DateTime.now(),
      emiAmount: (json['emiAmount'] as num?)?.toDouble(),
      nextDueDate: nextDue != null ? DateTime.parse(nextDue) : null,
      linkedAccountId: json['linkedAccountId'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': typeKey,
    'id': id,
    'lender': lender,
    'loanType': loanType,
    'principal': principal,
    'interestRate': interestRate,
    'tenureMonths': tenureMonths,
    'outstandingAmount': outstandingAmount,
    'startDate': startDate.toIso8601String(),
    if (emiAmount != null) 'emiAmount': emiAmount,
    if (nextDueDate != null) 'nextDueDate': nextDueDate!.toIso8601String(),
    if (linkedAccountId != null) 'linkedAccountId': linkedAccountId,
  };

  @override
  String toSemanticText() => '''
Loan Details:
Lender: $lender
Loan Type: $loanType
Principal Amount: $principal
Interest Rate: $interestRate%
Tenure: $tenureMonths months
Outstanding Amount: $outstandingAmount
Loan Start Date: ${startDate.toIso8601String()}
EMI: ${emiAmount ?? '-'} Next Due: ${nextDueDate?.toIso8601String() ?? '-'}
Linked Account: ${linkedAccountId ?? '-'}
''';
}

// ------------------------------
// NEW: Subscription
// ------------------------------
class SubscriptionEntity extends FinancialEntity {
  static const String typeKey = 'subscription';

  @override
  final String id;

  /// Provider/Service name (e.g., Netflix, YouTube Premium, JioFiber)
  final String provider;

  /// Plan label (e.g., Premium, Family, 300 Mbps)
  final String planName;

  final double amount;
  final String currency; // e.g., INR

  /// monthly | yearly | quarterly | weekly
  final String billingCycle;

  final DateTime nextBillingDate;
  final DateTime? lastPaymentDate;

  /// Card | UPI | AutoPay | AutoDebit
  final String? paymentMethod;

  /// active | paused | canceled
  final String status;

  /// If linked to an account for AutoPay
  final String? linkedAccountId;

  /// Whether auto-renew is on
  final bool autoRenew;

  final DateTime? startDate;
  final DateTime? endDate;

  SubscriptionEntity({
    required this.id,
    required this.provider,
    required this.planName,
    required this.amount,
    required this.currency,
    required this.billingCycle,
    required this.nextBillingDate,
    this.lastPaymentDate,
    this.paymentMethod,
    this.status = 'active',
    this.linkedAccountId,
    this.autoRenew = true,
    this.startDate,
    this.endDate,
  });

  @override
  String get type => typeKey;

  @override
  String get collectionName => 'subscriptions';

  factory SubscriptionEntity.fromJson(Map<String, dynamic> json) {
    final next = json['nextBillingDate'] as String?;
    final last = json['lastPaymentDate'] as String?;
    final start = json['startDate'] as String?;
    final end = json['endDate'] as String?;
    return SubscriptionEntity(
      id: json['id'] as String,
      provider: json['provider'] as String,
      planName: json['planName'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      billingCycle: json['billingCycle'] as String,
      nextBillingDate: next != null ? DateTime.parse(next) : DateTime.now(),
      lastPaymentDate: last != null ? DateTime.parse(last) : null,
      paymentMethod: json['paymentMethod'] as String?,
      status: (json['status'] as String?) ?? 'active',
      linkedAccountId: json['linkedAccountId'] as String?,
      autoRenew: (json['autoRenew'] as bool?) ?? true,
      startDate: start != null ? DateTime.parse(start) : null,
      endDate: end != null ? DateTime.parse(end) : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': typeKey,
    'id': id,
    'provider': provider,
    'planName': planName,
    'amount': amount,
    'currency': currency,
    'billingCycle': billingCycle,
    'nextBillingDate': nextBillingDate.toIso8601String(),
    if (lastPaymentDate != null)
      'lastPaymentDate': lastPaymentDate!.toIso8601String(),
    if (paymentMethod != null) 'paymentMethod': paymentMethod,
    'status': status,
    if (linkedAccountId != null) 'linkedAccountId': linkedAccountId,
    'autoRenew': autoRenew,
    if (startDate != null) 'startDate': startDate!.toIso8601String(),
    if (endDate != null) 'endDate': endDate!.toIso8601String(),
  };

  @override
  String toSemanticText() => '''
Subscription:
Provider: $provider
Plan: $planName
Amount: $amount $currency
Billing: $billingCycle
Status: $status
Next Billing: ${nextBillingDate.toIso8601String()}
Auto Renew: $autoRenew
Linked Account: ${linkedAccountId ?? '-'}
''';
}

final financialEntities = [
  {
    "type": "account",
    "id": "acc_1001",
    "bankName": "HDFC Bank",
    "accountType": "Savings",
    "balance": 184523.75,
    "holderName": "Nilesh Sahu",
    "accountNumberMasked": "XXXXXX4217",
    "ifsc": "HDFC0001234",
    "currency": "INR",
    "openedDate": "2019-06-14",
  },
  {
    "type": "account",
    "id": "acc_1002",
    "bankName": "State Bank of India",
    "accountType": "Current",
    "balance": 982345.20,
    "holderName": "Aurora Foods LLP",
    "accountNumberMasked": "XXXXXX9082",
    "ifsc": "SBIN0000456",
    "currency": "INR",
    "openedDate": "2021-02-01",
  },

  {
    "type": "loan",
    "id": "loan_2001",
    "lender": "ICICI Bank",
    "loanType": "Home Loan",
    "principal": 5200000,
    "interestRate": 8.35,
    "tenureMonths": 240,
    "outstandingAmount": 4632000,
    "startDate": "2023-10-05",
    "emiAmount": 44250,
    "nextDueDate": "2026-03-25",
    "linkedAccountId": "acc_1001",
  },
  {
    "type": "loan",
    "id": "loan_2002",
    "lender": "Bajaj Finance",
    "loanType": "Auto Loan",
    "principal": 850000,
    "interestRate": 9.75,
    "tenureMonths": 60,
    "outstandingAmount": 394200,
    "startDate": "2022-08-10",
    "emiAmount": 17890,
    "nextDueDate": "2026-03-10",
    "linkedAccountId": "acc_1001",
  },

  {
    "type": "investment",
    "id": "inv_3001",
    "instrument": "Mutual Fund",
    "name": "Mirae Asset Large Cap Fund - Direct Growth",
    "platform": "Groww",
    "investedAmount": 150000,
    "currentValue": 186450,
  },
  {
    "type": "investment",
    "id": "inv_3002",
    "instrument": "Mutual Fund",
    "name": "Axis Small Cap Fund - Direct Growth",
    "platform": "Kuvera",
    "investedAmount": 90000,
    "currentValue": 104380,
  },
  {
    "type": "investment",
    "id": "inv_3003",
    "instrument": "Stock",
    "name": "Tata Consultancy Services",
    "symbol": "TCS",
    "broker": "Zerodha",
    "qty": 25,
    "avgBuyPrice": 3540.5,
    "investedAmount": 88512.5,
    "currentValue": 103722.5,
  },
  {
    "type": "investment",
    "id": "inv_3004",
    "instrument": "Stock",
    "name": "HDFC Bank",
    "symbol": "HDFCBANK",
    "broker": "Angel One",
    "qty": 60,
    "avgBuyPrice": 1452.2,
    "investedAmount": 87132,
    "currentValue": 96522,
  },
  {
    "type": "investment",
    "id": "inv_3005",
    "instrument": "PPF",
    "name": "Public Provident Fund",
    "investedAmount": 450000,
    "currentValue": 528600,
  },
  {
    "type": "investment",
    "id": "inv_3006",
    "instrument": "Fixed Deposit",
    "name": "SBI FD - 1 Year",
    "rate": 6.8,
    "principal": 200000,
    "maturityDate": "2026-11-12",
    "investedAmount": 200000,
    "currentValue": 213600,
  },
  {
    "type": "investment",
    "id": "inv_3007",
    "instrument": "Gold ETF",
    "name": "Nippon India GoldBeES",
    "units": 120,
    "avgBuyPrice": 56.9,
    "investedAmount": 6828,
    "currentValue": 8172,
  },
  {
    "type": "investment",
    "id": "inv_3008",
    "instrument": "Index Fund",
    "name": "UTI Nifty 50 Index Fund - Direct Growth",
    "investedAmount": 110000,
    "currentValue": 139800,
  },
  {
    "type": "investment",
    "id": "inv_3009",
    "instrument": "NPS Tier I",
    "name": "NPS Active Choice",
    "investedAmount": 240000,
    "currentValue": 298400,
  },
  {
    "type": "investment",
    "id": "inv_3010",
    "instrument": "REIT",
    "name": "Embassy Office Parks REIT",
    "units": 180,
    "avgBuyPrice": 324.5,
    "investedAmount": 58410,
    "currentValue": 64116,
  },

  {
    "type": "subscription",
    "id": "sub_5001",
    "provider": "Netflix",
    "planName": "Premium",
    "amount": 1299,
    "currency": "INR",
    "billingCycle": "monthly",
    "nextBillingDate": "2026-03-03",
    "lastPaymentDate": "2026-02-03",
    "paymentMethod": "Card",
    "status": "active",
    "linkedAccountId": "acc_1001",
    "autoRenew": true,
    "startDate": "2022-09-15",
  },
  {
    "type": "subscription",
    "id": "sub_5002",
    "provider": "YouTube Premium",
    "planName": "Family",
    "amount": 899,
    "currency": "INR",
    "billingCycle": "monthly",
    "nextBillingDate": "2026-03-04",
    "lastPaymentDate": "2026-02-04",
    "paymentMethod": "Card",
    "status": "active",
    "linkedAccountId": "acc_1001",
    "autoRenew": true,
    "startDate": "2021-06-01",
  },
  {
    "type": "subscription",
    "id": "sub_5003",
    "provider": "JioFiber",
    "planName": "300 Mbps Unlimited",
    "amount": 1450,
    "currency": "INR",
    "billingCycle": "monthly",
    "nextBillingDate": "2026-03-05",
    "lastPaymentDate": "2026-02-05",
    "paymentMethod": "AutoPay",
    "status": "active",
    "linkedAccountId": "acc_1001",
    "autoRenew": true,
    "startDate": "2023-01-10",
  },

  {
    "type": "transaction",
    "id": "txn_4001",
    "amount": 190500,
    "currency": "INR",
    "category": "Salary",
    "description": "February Salary - Aurora Systems Pvt Ltd",
    "merchant": "Aurora Payroll",
    "mode": "NEFT",
    "direction": "credit",
    "date": "2026-02-29T10:03:00+05:30",
    "accountId": "acc_1001",
  },
  {
    "type": "transaction",
    "id": "txn_4002",
    "amount": 44250,
    "currency": "INR",
    "category": "EMI",
    "description": "Home Loan EMI",
    "merchant": "ICICI Bank",
    "mode": "NACH",
    "direction": "debit",
    "date": "2026-02-25T08:00:00+05:30",
    "accountId": "acc_1001",
    "loanId": "loan_2001",
  },
  {
    "type": "transaction",
    "id": "txn_4003",
    "amount": 1299,
    "currency": "INR",
    "category": "Subscription",
    "description": "Netflix Premium - Feb",
    "merchant": "Netflix",
    "mode": "Card",
    "direction": "debit",
    "date": "2026-02-03T09:10:00+05:30",
    "accountId": "acc_1001",
  },
  {
    "type": "transaction",
    "id": "txn_4004",
    "amount": 3655,
    "currency": "INR",
    "category": "Groceries",
    "description": "Monthly groceries",
    "merchant": "Reliance Smart",
    "mode": "UPI",
    "direction": "debit",
    "date": "2026-02-02T18:45:00+05:30",
    "accountId": "acc_1001",
  },
];
