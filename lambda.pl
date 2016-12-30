use strict;
use warnings;

require lambdaFunctions;

## Here begins the main program body
#my @numbers = ("","\\fx.f(x)");

system("clear");
#@numbers contains the numbers 1-10 in the indeces 0-9 ( 1 is in $numbers[0] , etc. )
#print lambdaFunctions::get_number(9) . "\n";
#print lambdaFunctions::get_number(10) . "\n";
#print lambdaFunctions::get_number(95) . "\n";
#for(my $i = 1; $i <= 10; $i++ )
#{
#	push @numbers, lambdaFunctions::successor($numbers[$i]);
#}
#
print "This is lambda calculus!\n";
print "The symbol for lambda is represented by the '\\' symbol\n";

#print "4 + 3 = ", lambdaFunctions::plus($numbers[4], $numbers[3]), "\n";
#print "4 * 3 = ", lambdaFunctions::multiply($numbers[4], $numbers[3]), "\n";
#print "4 ^ 3 = ", lambdaFunctions::exponent($numbers[4], $numbers[3]), "\n";
#
my $first_num;
my $operator;
my $second_num;
do
{
	print "Enter a positive integer: ";
	$first_num = <STDIN>;
	chomp($first_num);
}while($first_num < 1);
do
{
	print "Enter + * or ^ ";
	$operator = <STDIN>;
	chomp($operator);
}until($operator eq '+' || $operator eq '*' || $operator eq '^');
do
{
	print "Enter a second positive integer: ";
	$second_num = <STDIN>;
	chomp($second_num);
}while($second_num < 1);

print "$first_num $operator $second_num = ";

if($operator eq '+')
{
	print lambdaFunctions::plus(lambdaFunctions::get_number($first_num), lambdaFunctions::get_number($second_num)), "\n";
}elsif($operator eq '*')
{
	print lambdaFunctions::multiply(lambdaFunctions::get_number($first_num), lambdaFunctions::get_number($second_num)), "\n";
}elsif($operator eq '^')
{
	print lambdaFunctions::exponent(lambdaFunctions::get_number($first_num), lambdaFunctions::get_number($second_num)), "\n";
}
