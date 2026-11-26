function [below, above, gap_below, gap_above] = neighbor_doubles(x)
% NEIGHBOR_DOUBLES  The doubles immediately below and above x, and the gaps to them.
%
%   [below, above, gap_below, gap_above] = neighbor_doubles(x)
%
%   Neighbouring doubles differ by exactly one in their 64-bit integer
%   representation, so the neighbours are found by adding and subtracting 1
%   to that integer. Every real number between below and above is stored as
%   one of the three.
%
%   EXAMPLE
%     [lo, hi] = neighbor_doubles(1);
%     hi - 1        % ans = 2.2204e-16   (machine epsilon)
%     1 - lo        % ans = 1.1102e-16   (spacing halves below a power of two)
%
%   See also: encode_ieee754_double, eps

  if nargin != 1
    print_usage();
  end
  if ! (isscalar(x) && isreal(x) && isfinite(x))
    error("neighbor_doubles:badInput", "x must be a finite real scalar.");
  end
  if x == 0
    tiny = 2^-1074;
    below = -tiny;  above = tiny;
  else
    u = typecast(double(x), "uint64");
    up   = typecast(u + 1, "double");
    down = typecast(u - 1, "double");
    if x > 0
      above = up;    below = down;
    else
      above = down;  below = up;
    end
  end
  gap_below = x - below;
  gap_above = above - x;
end

%!test
%! [lo, hi] = neighbor_doubles(1);
%! assert(hi - 1, eps);
%! assert(1 - lo, eps / 2);

%!test
%! [lo, hi] = neighbor_doubles(-1);
%! assert(hi, -1 + eps / 2);
%! assert(lo, -1 - eps);

%!test
%! [lo, hi] = neighbor_doubles(0);
%! assert(hi, 2^-1074);
