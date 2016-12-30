use strict;
use warnings;

package lambdaFunctions;

my %cache = ();
my @primes = (2);

#takes an expression with 2 variables and replaces them with 'f' and 'x'
sub cleanUpVariables #takes an input of a single string with 2 variables
{
	my $string = shift;
	#print "Cleaning up $string\n";

	# we need to clean up all the '\.' style variable declarations into one
	$string =~ s/\.\\//g;

	# change variables to 'f' and 'x'
	my %variables = (substr($string, 1, 1) => "f", substr($string, 2, 1) => "x");
	my $variables = join("|", keys %variables);	# e.g. "a|b"
	$variables = qr/$variables/;
	$string =~ s/($variables)/$variables{$1}/g;	# gotta love regex

	return $string;
}

# returns argument1 ^ argument2
sub exponent # input (number1 number2) both in \fx.f(x) form
{
	my @operands = (shift, shift);

	# the operands need to use unique variables, so we'll use a b c d
	$operands[0] =~ s/f/a/g;
	$operands[0] =~ s/x/b/g;
	$operands[1] =~ s/f/c/g;
	$operands[1] =~ s/x/d/g;

	my $result = $operands[1] . "(" . $operands[0] . ")"; # this formula is very simple
	return simplify($result);
}

# returns the index of the matching parenthesis--capable of searching forward or backward
# it would be nice to add {} and [] finding capabilities
sub findParenthesis # input (string to be searched, index of parenthesis)
{
	my $string = shift;
	my $indexCounter = shift;
	
	# we need to know if we're looking at a '(' or a ')'
	my $foundCharacter = substr($string, $indexCounter, 1);
	
	# this variable counts what inception level we're at
	my $parenthesisCounter = 0;

	# this variable only matters if set to 1
	my $reversed = 0;

	#if the given character is a left parenthesis, search forward
	if($foundCharacter eq ")")
	{
		$reversed = 1;
		$indexCounter = ((length $string) - $indexCounter) - 1;
		$string = reverse($string);
	}
	do {
		if($string =~ /.{$indexCounter}[()]/) # we're looking for a parenthesis with a indexCounter sized buffer before it
		{
			$indexCounter += $-[0]; # $-[0] tells us how far into the string it found the beginning of the indexCounter sized buffer, so we add that to indexCounter
			my $parenthesis = substr($string, $indexCounter, 1);
			if($parenthesis eq ")")
			{
				$parenthesisCounter--;
			}
			elsif($parenthesis eq "(")
			{
				$parenthesisCounter++;
			}
			else
			{
				# I don't know how you could possibly get here...
				print "Check your code in findParenthesis()\n";
			}
			$indexCounter++; # ready to look at the next character
		}
		else
		{
			# the program should never enter this loop
			# maybe figure out a way to return an error code
			print "Something went wrong in findParenthesis()\n";
			last;
		}
	} while($parenthesisCounter != 0); # the first iteration will set this counter to 1 or -1 ; once this value is 0 we know we've found the matching parenthesis
	$indexCounter--; # we don't want to look at the next character anymore

	if($reversed)
	{
		$indexCounter = ((length $string) - $indexCounter) - 1;	
	}
	return $indexCounter;
}

sub get_number
{
	my $number = shift;
	#print "Called get_number($number)\n";
	my $string = "\\fx.f(x)";
	if($number == 1)
	{
		return $string;
	}
	elsif($number <= 0)
	{
		return 0;
	}
	elsif(exists $cache{$number})
	{
		return $cache{$number};
	}
	my %factorization = prime_factorization($number);
	#my @factorization = ();
	#foreach my $f (keys %factorization)
	#{
	#	push @factorization, $f, $factorization{$f};
	#}
	#print join(', ', @factorization) . "\n";
	if(exists $factorization{$number})
	{
		if(!exists $cache{$number})
		{
			$cache{$number} = successor(get_number($number-1));
		}
		return $cache{$number};
	}
	foreach my $key (keys %factorization)
	{
		for(my $i = $factorization{$key}; $i > 0; --$i)
		{
			$string = multiply($string, successor(get_number($key-1)));
		}
	}
	#print "Returning from get_number($number)\n";
	return $string;
}

sub is_prime
{
	my $number = shift;
	#print "Called is_prime($number)\n";
	foreach my $prime (@primes)
	{
		if($prime ** 2 > $number)
		{
			return 1;
		}
		elsif($number % $prime == 0)
		{
			return 0;
		}
	}
	do
	{
		push @primes, next_prime($primes[-1]);
		if($number % $primes[-1] == 0)
		{
			return 0;
		}
	}while($primes[-1] ** 2 < $number);
	return 1;
}

sub multiply
{
	my @operands = (shift, shift);

	$operands[0] =~ s/f/a/g;
	$operands[0] =~ s/x/b/g;
	$operands[1] =~ s/f/c/g;
	$operands[1] =~ s/x/d/g;

	my $product = "\\pox.p(o(x))($operands[0],$operands[1])";
	return simplify($product);
}

sub next_prime
{
	my $number = shift;
	#print "Called next_prime($number)\n";
	while(!is_prime(++$number)){}
	return $number;
}

sub plus #input should be 2 strings containing only 'f' and 'x' as variables
{
	#unpack my @operands[2] from @_
	my @operands = (shift, shift);

	#replace letters in operands to avoid collision
	$operands[0] =~ s/f/a/g;
	$operands[0] =~ s/x/b/g;
	$operands[1] =~ s/f/c/g;
	$operands[1] =~ s/x/d/g;

	my $sum = "\\pofx.p(f,o(f,x))($operands[0],$operands[1])";
	return simplify($sum);
}

sub prime_factorization
{
	my $number = shift;
	#print "Called prime_factorization($number)\n";
	my %factors = ();
	if($number < $primes[0])
	{
		return %factors;
	}
	for(my $i = 0; $number > 1; $i++)
	{
		if($i == scalar @primes)
		{
			push @primes, next_prime($primes[-1]);
		}
		if($primes[$i] ** 2 > $number)
		{
			$factors{$number} = 1;
			return %factors;
		}
		if($number % $primes[$i] == 0)
		{
			$factors{$primes[$i]} = 0;
			do
			{
				++$factors{$primes[$i]};
				$number /= $primes[$i];
			}while($number % $primes[$i] == 0);
		}	
	}
	return %factors;
}

sub simplify #input should be a string to simplify
{
	#unpack $string from @_
	my $string = shift;

	#while there's an instance of ")(" in $string
	while($string =~ /\)\((?!.*\)\()/)
	{
		#$argumentIndex = the index right after the last ")(" 
		my $argumentsIndex = $+[0];

		#$argumentsLength = the index of the matching ")" minus $argumentIndex
		my $argumentsEnd = findParenthesis($string, $argumentsIndex - 1);
		my $argumentsLength = $argumentsEnd - $argumentsIndex;

		#$arguments = substr($string, $argumentIndex, $argumentsLength)
		my $arguments = substr($string, $argumentsIndex, $argumentsLength);
		my @arguments = split(',', $arguments);

		#delete the parentheses and $argumentIndex--
		my $segment1 = substr($string, 0, $argumentsIndex-1);
		if($argumentsEnd + 1 < length $string)
		{
			my $segment2 = substr($string, $argumentsEnd + 1);
			$string = $segment1 . $segment2;
		}
		else
		{
			$string = $segment1;
		}
		$argumentsIndex--;

		#find the "(" for the ")" found in the original ")("
		my $functionIndex = findParenthesis($string, $argumentsIndex - 1);

		#find the lambda directly before this parenthesis
		substr($string, 0, $functionIndex) =~ /\\(?!.*\\)/;

		#$replacementIndex = index of the first letter after "\"
		my $replacementIndex = $-[0] + 1;

		#foreach @arguments
		foreach(@arguments)
		{
			#$firstVariable = the letter at $replacementIndex
			my $firstVariable = substr($string, $replacementIndex, 1);

			#divide $string at each instance of $firstVariable and store the parts to @segments
			my @segments;
			my $segments = substr($string, $replacementIndex - 1);
	
			while($segments =~ /$firstVariable/)
			{
				push @segments, substr($segments, 0, $-[0]);
				$segments = substr($segments, $+[0]);
			}
			push @segments, $segments;
			$segments[0] = (shift @segments) . $segments[0];

			#replace all instances of $firstVariable with $_
			$string = substr($string, 0, $replacementIndex - 1) . join($_, @segments);

			#delete all instances of "\."
			$string =~ s/\\\.//g;
		}	
	}
	return cleanUpVariables($string);
}

#returns the input value plus 1
sub successor #takes as an input a single string of the form '\fx.f(x)'
{
	my $startingValue = shift;

	$startingValue =~ s/f/a/g;
	$startingValue =~ s/x/b/g;

	my $nextValue = "\\pfx.f(p(f,x))($startingValue)";

	return simplify($nextValue);
}

return 1;
