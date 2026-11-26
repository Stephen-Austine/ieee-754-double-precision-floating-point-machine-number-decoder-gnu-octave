function r = ieee754_report(input)
% IEEE754_REPORT  Print a step-by-step decoding of a number or a 64-bit string.
%
%   ieee754_report(0.1)
%   ieee754_report("0 10000000011 1011100100010...")
%   r = ieee754_report(input)        % also returns decode_ieee754_double's struct
%
%   See also: decode_ieee754_double, encode_ieee754_double, neighbor_doubles

  if nargin != 1
    print_usage();
  end
  if ischar(input)
    bits = input(! isspace(input));
  else
    bits = encode_ieee754_double(input);
  end
  r = decode_ieee754_double(bits);

  printf("Bit pattern  : %s %s %s\n", r.sign_bit, r.exponent_bits, r.fraction_bits);
  printf("               S  E (11 bits)   F (52 bits)\n\n");
  printf("Sign         : S = %s   ->  (-1)^%s = %+d\n", r.sign_bit, r.sign_bit, r.sign);
  printf("Exponent     : E = %s (binary) = %d\n", r.exponent_bits, r.exponent_field);
  switch r.class
    case "normal"
      printf("               unbiased exponent e = E - 1023 = %d\n", r.exponent);
    case "subnormal"
      printf("               E = 0 -> subnormal, exponent fixed at -1022\n");
    otherwise
      printf("               E = 2047 -> special value\n");
  end
  printf("Fraction     : F = %.17g\n", r.fraction);
  if strcmp(r.class, "normal")
    printf("Significand  : 1 + F = %.17g\n", r.significand);
    printf("Value        : %+d x 2^%d x %.17g\n", r.sign, r.exponent, r.significand);
  end
  printf("Class        : %s\n", r.class);
  printf("Value        : %.17g\n", r.value);
  printf("Hardware says: %.17g   (%s)\n", r.value_check, ifelse_str(r.matches));

  if isfinite(r.value)
    [lo, hi, glo, ghi] = neighbor_doubles(r.value);
    printf("\nNeighbours   : %.17g   (gap %.3e)\n", lo, glo);
    printf("               %.17g   (gap %.3e)\n", hi, ghi);
  end
end

function s = ifelse_str(flag)
  if flag
    s = "agrees";
  else
    s = "DISAGREES";
  end
end
