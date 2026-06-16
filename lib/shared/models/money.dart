class Money {
  final int amount;

  const Money(this.amount);

  Money operator +(Money other) => Money(amount + other.amount);
  Money operator -(Money other) => Money(amount - other.amount);
  Money operator *(int factor) => Money(amount * factor);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Money && amount == other.amount);

  @override
  int get hashCode => amount.hashCode;
}
