function [bits, fields] = encode_ieee754_double(x)
% ENCODE_IEEE754_DOUBLE  The 64 IEEE 754 bits of a double, as text.
%
%   bits = encode_ieee754_double(x)
%   [bits, fields] = encode_ieee754_double(x)
%
%   OUTPUT  bits    64 characters: sign (1) + exponent (11) + fraction (52)
%           fields  struct with the strings sign, exponent and fraction
%
%   EXAMPLE
%     encode_ieee754_double(1)
%     % ans = 0011111111110000000000000000000000000000000000000000000000000000
%
%   See also: decode_ieee754_double, bits_to_double

  if nargin != 1
    print_usage();
  end
  if ! (isscalar(x) && isreal(x) && isnumeric(x))
    error("encode_ieee754_double:badInput", "x must be a real numeric scalar.");
  end
  u = typecast(double(x), "uint64");
  b = bitget(u, 64:-1:1);                 % most significant bit first
  bits = char("0" + double(b));
  fields = struct("sign", bits(1), "exponent", bits(2:12), "fraction", bits(13:64));
end

%!assert(encode_ieee754_double(1), ["0" "01111111111" repmat("0", 1, 52)])
%!assert(encode_ieee754_double(-0), ["1" repmat("0", 1, 63)])
%!assert(encode_ieee754_double(0.5)(1:12), "001111111110")
%!assert(numel(encode_ieee754_double(pi)), 64)
