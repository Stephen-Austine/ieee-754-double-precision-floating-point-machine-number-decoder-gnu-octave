% DEMO_IEEE754  Reproduces the original floating-point analysis and extends it.
%
%   Run from the project root:
%       octave --no-gui src/demo_ieee754.m

here = fileparts(mfilename("fullpath"));
addpath(here);

sign_bit = "0";
exponent = "10000000011";
fraction = "1011100100010000000000000000000000000000000000000001";

printf("\n=== 1. The machine number from the original notes ===\n\n");
printf("fraction field has %d bits\n\n", numel(fraction));
r = ieee754_report([sign_bit exponent fraction]);

printf("\n=== 2. Correction to the original worked solution ===\n\n");
printf("%-38s: 0.72235107421875\n", "fraction value stated in the notes");
printf("%-38s: %.17g\n", "fraction value computed here", r.fraction);
printf("%-38s: %.3e\n", "difference", abs(r.fraction - 0.72235107421875));
printf("%-38s: %.17g\n", "correct value of the number", r.value);
printf("%-38s: 2^4 * 1.72235107421875 = %.14g  (wrong)\n", "value the notes' fraction would give", 16 * 1.72235107421875);

printf("\n=== 3. The classic textbook neighbour: trailing bit set to 0 ===\n\n");
classic = [sign_bit exponent "1011100100010" repmat("0", 1, 39)];
rc = decode_ieee754_double(classic);
printf("with F = .1011100100010 followed by zeros : %.17g\n", rc.value);
printf("the number above is its immediate successor: %.17g\n", r.value);
printf("gap between them (one unit in the last place): %.4e = 2^-48\n", r.value - rc.value);

printf("\n=== 4. Encode then decode a few familiar numbers ===\n\n");
for x = [1, -2, 0.5, 0.1, pi, 1e300]
  b = encode_ieee754_double(x);
  d = decode_ieee754_double(b);
  printf("%-12g %s %s %s -> %.17g\n", x, b(1), b(2:12), b(13:end), d.value);
end

printf("\n=== 5. Special values ===\n\n");
for x = [0, -0, Inf, -Inf, NaN, realmin, realmin / 2^10, 2^-1074, realmax]
  d = decode_ieee754_double(encode_ieee754_double(x));
  printf("%-24.17g %-10s E=%4d\n", x, d.class, d.exponent_field);
end

printf("\n=== 6. Why 0.1 + 0.2 != 0.3 ===\n\n");
printf("0.1       = %.20f\n", 0.1);
printf("0.2       = %.20f\n", 0.2);
printf("0.1 + 0.2 = %.20f\n", 0.1 + 0.2);
printf("0.3       = %.20f\n", 0.3);
printf("(0.1 + 0.2) == 0.3 : %d,   difference = %.3e = %g ulp\n", ...
       (0.1 + 0.2) == 0.3, (0.1 + 0.2) - 0.3, ((0.1 + 0.2) - 0.3) / eps(0.3));

printf("\n=== 7. Spacing of doubles ===\n\n");
printf("%12s %16s %18s\n", "x", "spacing eps(x)", "spacing / x");
for x = [1e-10, 1, 1e3, 1e10, 1e16, 1e100]
  printf("%12.0e %16.4e %18.4e\n", x, eps(x), eps(x) / x);
end
printf("\n2^53     = %.0f\n2^53 + 1 = %.0f   (not representable: rounds back)\n\n", 2^53, 2^53 + 1);
