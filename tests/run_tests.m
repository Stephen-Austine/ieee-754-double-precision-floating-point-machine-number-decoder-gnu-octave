% RUN_TESTS  Self-checking test-suite for the IEEE 754 decoder project.
%
%   Run from the project root:
%       octave --no-gui tests/run_tests.m
%
%   Exits with status 1 if anything fails, so it works in CI.

1;

function run_case(name, fn)
  global n_fail n_pass
  try
    fn();
    n_pass += 1;
    printf("  PASS  %s\n", name);
  catch err
    n_fail += 1;
    printf("  FAIL  %s\n        %s\n", name, err.message);
  end
end

function check_roundtrip()
  rand("seed", 42);
  xs = [1, -1, 0.1, pi, exp(1), 1e-300, 1e300, realmin, realmax, 2^-1074, 123456789.123456789, ...
        (rand(1, 200) - 0.5) .* 10 .^ (20 * (rand(1, 200) - 0.5))];
  for x = xs
    d = decode_ieee754_double(encode_ieee754_double(x));
    assert(d.value, x);
    assert(d.matches);
  end
end

function check_manual_matches_hardware()
  rand("seed", 7);
  for k = 1:300
    bits = char("0" + (rand(1, 64) > 0.5));
    d = decode_ieee754_double(bits);
    assert(d.matches, "mismatch for %s", bits);
  end
end

function check_original_number()
  bits = ["0" "10000000011" "1011100100010000000000000000000000000000000000000001"];
  d = decode_ieee754_double(bits);
  assert(d.exponent_field, 1027);
  assert(d.exponent, 4);
  assert(d.fraction, 0.722900390625 + 2^-52, 1e-18);
  assert(d.value, 27.56640625 + 2^-48);
  assert(d.class, "normal");
  assert(d.fraction != 0.72235107421875);           % the value quoted in the notes was wrong
end

function check_successor_of_textbook_number()
  classic = ["0" "10000000011" "1011100100010" repmat("0", 1, 39)];
  assert(decode_ieee754_double(classic).value, 27.56640625);
  [~, above] = neighbor_doubles(27.56640625);
  assert(above, 27.56640625 + 2^-48);
end

function check_classes()
  z = repmat("0", 1, 52);  o = repmat("1", 1, 11);
  assert(decode_ieee754_double(["0" repmat("0", 1, 11) z]).class, "zero");
  assert(decode_ieee754_double(["0" repmat("0", 1, 11) "1" repmat("0", 1, 51)]).class, "subnormal");
  assert(decode_ieee754_double(["0" o z]).class, "infinity");
  assert(decode_ieee754_double(["0" o "1" repmat("0", 1, 51)]).class, "NaN");
  assert(decode_ieee754_double(["0" "01111111111" z]).class, "normal");
end

function check_negative_zero()
  d = decode_ieee754_double(["1" repmat("0", 1, 63)]);
  assert(d.class, "zero");
  assert(1 / d.value, -Inf);
  assert(d.matches);
end

function check_neighbours_are_adjacent()
  for x = [1, 0.1, 1e10, 3.5, 2^30, 1e-300, -7.25]
    [lo, hi, glo, ghi] = neighbor_doubles(x);
    assert(lo < x && x < hi);
    assert(ghi, hi - x);
    assert(glo, x - lo);
    % nothing strictly between: the midpoint rounds to one of the three
    mid = x + (hi - x) / 2;
    assert(any(mid == [x, hi]));
  end
end

function check_eps()
  [~, hi] = neighbor_doubles(1);
  assert(hi - 1, eps);
  assert(eps(1), 2^-52);
end

function check_error(fn, id)
  try
    fn();
  catch err
    assert(err.identifier, id);
    return;
  end
  error("expected error %s", id);
end

global n_fail n_pass
n_fail = 0;  n_pass = 0;

here = fileparts(mfilename("fullpath"));
addpath(fullfile(here, "..", "src"));

printf("\nIEEE 754 decoder project tests\n==============================\n");
run_case("1.0 encodes as 0 01111111111 000...",    @() assert(encode_ieee754_double(1), ["0" "01111111111" repmat("0", 1, 52)]));
run_case("encode/decode round trip (210 values)",  @check_roundtrip);
run_case("manual decoding = hardware (300 random patterns)", @check_manual_matches_hardware);
run_case("the machine number from the notes",      @check_original_number);
run_case("it is the successor of 27.56640625",     @check_successor_of_textbook_number);
run_case("zero / subnormal / inf / NaN / normal",  @check_classes);
run_case("negative zero",                          @check_negative_zero);
run_case("neighbours are adjacent doubles",        @check_neighbours_are_adjacent);
run_case("machine epsilon = 2^-52",                @check_eps);
run_case("0.1 + 0.2 is exactly one ulp above 0.3", @() assert((0.1 + 0.2) - 0.3, eps(0.3)));
run_case("2^53 + 1 rounds back to 2^53",           @() assert(2^53 + 1, 2^53));
run_case("spaces in the bit string are ignored",   @() assert(decode_ieee754_double("0 01111111111 0000000000000000000000000000000000000000000000000000").value, 1));
run_case("error id: wrong length",                 @() check_error(@() decode_ieee754_double("0101"), "decode_ieee754_double:badInput"));
run_case("error id: non-binary character",         @() check_error(@() decode_ieee754_double(repmat("2", 1, 64)), "decode_ieee754_double:badInput"));
run_case("error id: non-finite neighbour input",   @() check_error(@() neighbor_doubles(Inf), "neighbor_doubles:badInput"));

for name = {"bits_to_double", "encode_ieee754_double", "decode_ieee754_double", "neighbor_doubles"}
  [n, nmax] = test(name{1}, "quiet");
  run_case(sprintf("built-in tests of %s.m (%d/%d)", name{1}, n, nmax), @() assert(n, nmax));
end

printf("\n%d passed, %d failed\n\n", n_pass, n_fail);
if n_fail > 0
  exit(1);
end
