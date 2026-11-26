function r = decode_ieee754_double(bits)
% DECODE_IEEE754_DOUBLE  Decode a 64-bit IEEE 754 binary64 machine number by hand.
%
%   r = decode_ieee754_double(bits)
%
%   bits is a string of 64 binary digits (spaces allowed), laid out as
%
%       sign (1 bit) | exponent (11 bits) | fraction (52 bits)
%
%   The value is rebuilt step by step from the definition:
%
%       normal     (0 < E < 2047)   (-1)^S * 2^(E - 1023) * (1 + F)
%       subnormal  (E = 0, F > 0)   (-1)^S * 2^(-1022)    * F
%       zero       (E = 0, F = 0)   +0 or -0
%       infinity   (E = 2047, F = 0)
%       NaN        (E = 2047, F > 0)
%
%   where E is the exponent field read as an unsigned integer and
%   F = sum( f_i * 2^(-i) ) is the fraction field read as a binary fraction.
%
%   OUTPUT  r   struct with fields
%       sign_bit, exponent_bits, fraction_bits, sign, exponent_field,
%       exponent, fraction, significand, class, value, value_check, matches
%
%   value_check comes from the hardware (bits_to_double) and matches says
%   whether the manual arithmetic agrees with it.
%
%   EXAMPLE
%     r = decode_ieee754_double(["0" "10000000011" "1011100100010" repmat("0", 1, 39)]);
%     printf("%.17g\n", r.value);          % 27.56640625
%
%   See also: encode_ieee754_double, bits_to_double, ieee754_report

  if nargin != 1
    print_usage();
  end
  s = bits(! isspace(bits));
  if numel(s) != 64 || ! all(ismember(s, "01"))
    error("decode_ieee754_double:badInput", ...
          "Need exactly 64 binary digits (spaces allowed), got %d characters.", numel(s));
  end

  sign_bit      = s(1);
  exponent_bits = s(2:12);
  fraction_bits = s(13:64);

  S = double(sign_bit == "1");
  E = 0;
  for i = 1:11
    E = E * 2 + double(exponent_bits(i) == "1");        % binary -> integer
  end
  % fraction as a binary fraction; exact because every partial sum is a
  % multiple of 2^-52 below 2, so it is representable
  F = sum((fraction_bits == "1") .* 2 .^ (-(1:52)));

  if E == 0 && F == 0
    cls = "zero";           significand = 0;       e = -1022;  value = (-1)^S * 0;
  elseif E == 0
    cls = "subnormal";      significand = F;       e = -1022;  value = (-1)^S * 2^(-1022) * F;
  elseif E == 2047 && F == 0
    cls = "infinity";       significand = NaN;     e = 1024;   value = (-1)^S * Inf;
  elseif E == 2047
    cls = "NaN";            significand = NaN;     e = 1024;   value = NaN;
  else
    cls = "normal";         significand = 1 + F;   e = E - 1023;
    value = (-1)^S * 2^e * significand;
  end

  value_check = bits_to_double(s);
  if isnan(value)
    matches = isnan(value_check);
  else
    matches = (value == value_check) && (sign(1 / value) == sign(1 / value_check));
  end

  r = struct("sign_bit", sign_bit, "exponent_bits", exponent_bits, ...
             "fraction_bits", fraction_bits, "sign", (-1)^S, ...
             "exponent_field", E, "exponent", e, "fraction", F, ...
             "significand", significand, "class", cls, "value", value, ...
             "value_check", value_check, "matches", matches);
end

%!test
%! r = decode_ieee754_double(["0" "01111111111" repmat("0", 1, 52)]);
%! assert(r.value, 1);
%! assert(r.class, "normal");
%! assert(r.exponent, 0);

%!test
%! r = decode_ieee754_double(["0" "10000000011" "1011100100010" repmat("0", 1, 39)]);
%! assert(r.value, 27.56640625);
%! assert(r.exponent, 4);
%! assert(r.fraction, 0.722900390625);

%!test
%! r = decode_ieee754_double(["0" repmat("0", 1, 11) repmat("0", 1, 51) "1"]);
%! assert(r.class, "subnormal");
%! assert(r.value, 2^-1074);

%!test
%! r = decode_ieee754_double(["1" repmat("1", 1, 11) repmat("0", 1, 52)]);
%! assert(r.value, -Inf);
%! assert(r.class, "infinity");
