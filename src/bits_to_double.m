function x = bits_to_double(bits)
% BITS_TO_DOUBLE  Reinterpret a 64-character bit string as an IEEE 754 double.
%
%   x = bits_to_double(bits)
%
%   The string may contain spaces (they are ignored). The bits are packed into
%   a 64-bit unsigned integer which is then reinterpreted with typecast(), so
%   this is the machine's own opinion of what the number is - independent of
%   the arithmetic in decode_ieee754_double().
%
%   See also: decode_ieee754_double, encode_ieee754_double

  if nargin != 1
    print_usage();
  end
  s = bits(! isspace(bits));
  if numel(s) != 64 || ! all(ismember(s, "01"))
    error("bits_to_double:badInput", ...
          "Need exactly 64 binary digits (spaces allowed), got %d characters.", numel(s));
  end
  u = uint64(0);
  for i = 1:64
    u = bitor(bitshift(u, 1), uint64(s(i) == "1"));
  end
  x = typecast(u, "double");
end

%!assert(bits_to_double(["0" "01111111111" repmat("0", 1, 52)]), 1)
%!assert(bits_to_double(["1" "10000000000" repmat("0", 1, 52)]), -2)
%!assert(bits_to_double("0 11111111111 0000000000000000000000000000000000000000000000000000"), Inf)
%!error <64 binary digits> bits_to_double("0101")
