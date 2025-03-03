import '1.dart';

List<money> geter() {
  money upwork = money();
  upwork.name = 'Transaction 1';
  upwork.fee = '+\$${650}';
  upwork.time = 'aujour\'hui';
  upwork.image = 'Transfer.png';
  upwork.buy = false;
  money starbucks = money();
  starbucks.buy = true;
  starbucks.fee = '-\$${650}';
  starbucks.image = 'Transfer.png';
  starbucks.name = 'Transaction 2';
  starbucks.time = 'hier';
  money trasfer = money();
  trasfer.buy = true;
  trasfer.fee = '-\$${100}';
  trasfer.image = 'Transfer.png';
  trasfer.name = 'Transaction 3';
  trasfer.time = 'jan 30,2022';
  money depot = money();
  depot.buy = false;
  depot.fee = '+\$${1650}';
  depot.image = 'Transfer.png';
  depot.name = 'Transaction 4';
  depot.time = 'juin 30,2022';
  return [upwork, starbucks, trasfer, depot];
}
