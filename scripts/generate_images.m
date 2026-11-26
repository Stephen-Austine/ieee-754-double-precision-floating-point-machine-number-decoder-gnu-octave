% GENERATE_IMAGES  Re-create every plot used in README.md.
%
%   Run from the project root:
%       octave --no-gui scripts/generate_images.m

here = fileparts(mfilename("fullpath"));
root_dir = fullfile(here, "..");
addpath(fullfile(root_dir, "src"));
addpath(here);
out = fullfile(root_dir, "images");
if ! exist(out, "dir"), mkdir(out); end

BLUE = [0.11 0.35 0.75];  RED = [0.85 0.20 0.15];  GREEN = [0.10 0.60 0.35];
ORANGE = [0.95 0.55 0.10]; GREY = [0.45 0.45 0.45];
C_SIGN = [0.96 0.78 0.76]; C_EXP = [1.00 0.88 0.62]; C_FRAC = [0.76 0.85 0.96];

bits = ["0" "10000000011" "1011100100010000000000000000000000000000000000000001"];
r = decode_ieee754_double(bits);

% ------------------------------------------------------------------ 1  bit layout
fig = figure("visible", "off", "position", [100 100 1400 520]);
axes("position", [0.02 0.02 0.96 0.96]); hold on; axis([-0.5 64.5 -5.4 4.4]); axis off;
for i = 1:64
  if i == 1, fc = C_SIGN; elseif i <= 12, fc = C_EXP; else fc = C_FRAC; end
  rectangle("position", [i - 1 0 1 1.3], "facecolor", fc, "edgecolor", [0.35 0.35 0.35]);
  text(i - 0.5, 0.65, bits(i), "horizontalalignment", "center", "fontsize", 11, "fontweight", "bold");
end
% brackets
bracket = @(x1, x2, y, col) plot([x1 x1 x2 x2], [y + 0.3 y y y + 0.3], "-", "color", col, "linewidth", 3);
bracket(0.05, 0.95, -0.4, RED);      bracket(1.05, 11.95, -0.4, ORANGE);   bracket(12.05, 63.95, -0.4, BLUE);
text(0.5, -1.15, "S", "horizontalalignment", "center", "fontsize", 14, "color", RED, "fontweight", "bold");
text(6.5, -1.15, "exponent field E (11 bits)", "horizontalalignment", "center", "fontsize", 14, "color", [0.75 0.40 0.0], "fontweight", "bold");
text(38, -1.15, "fraction field F (52 bits)", "horizontalalignment", "center", "fontsize", 14, "color", BLUE, "fontweight", "bold");
text(0.3, -2.1, "sign:      S = 0   ->   (-1)^0 = +1", "horizontalalignment", "left", "fontsize", 13, "color", RED);
text(0.3, -2.9, sprintf("exponent:  E = 10000000011 (binary) = %d   ->   e = E - 1023 = %d", r.exponent_field, r.exponent), ...
     "horizontalalignment", "left", "fontsize", 13, "color", [0.75 0.40 0.0]);
text(0.3, -3.7, sprintf("fraction:  F = %.17g   ->   significand 1 + F = %.17g", r.fraction, r.significand), ...
     "horizontalalignment", "left", "fontsize", 13, "color", BLUE);
text(0.3, -4.7, sprintf("value = (+1) x 2^4 x 1.7229003906250002 = %.17g", r.value), "horizontalalignment", "left", ...
     "fontsize", 16, "fontweight", "bold");
text(32, 2.6, "The machine number from the original notes", "horizontalalignment", "center", "fontsize", 16, "fontweight", "bold");
text(32, 1.95, "64 bits = 1 sign + 11 exponent + 52 fraction", "horizontalalignment", "center", "fontsize", 12, "color", GREY);
save_figure(fig, fullfile(out, "machine-number-bit-layout.png"));

% ------------------------------------------------------------------ 2  spacing
fig = figure("visible", "off", "position", [100 100 1100 800]);
lx = linspace(-300, 300, 4000);                 % log10 of x
x = 10 .^ lx;
subplot(2, 1, 1);
plot(lx, log10(eps(x)), "-", "linewidth", 3, "color", BLUE); hold on;
plot(lx, lx, "--", "color", GREY, "linewidth", 1.5);
grid on; xlabel("log_{10}(x)"); ylabel("log_{10}( eps(x) )");
title("The gap between neighbouring doubles, eps(x), is x times about 10^{-16}");
legend("log_{10} eps(x)", "log_{10} x  (for comparison)", "location", "northwest");
subplot(2, 1, 2);
xs = 10 .^ linspace(0, 3, 3000);
semilogx(xs, (eps(xs) ./ xs) / 1e-16, "-", "linewidth", 2.5, "color", ORANGE); hold on;
semilogx([1 1000], [eps eps] / 1e-16, "--", "color", GREY); semilogx([1 1000], [eps / 2 eps / 2] / 1e-16, "--", "color", GREY);
grid on; xlabel("x"); ylabel("relative gap eps(x)/x  (units of 1e-16)");
title("Relative spacing saw-tooths between 2^{-53} = 1.11e-16 and 2^{-52} = 2.22e-16");
axis([1 1000 0 2.6]);
save_figure(fig, fullfile(out, "floating-point-spacing.png"));

% ------------------------------------------------------------------ 3  neighbours
[lo, hi, glo, ghi] = neighbor_doubles(27.56640625);
fig = figure("visible", "off", "position", [100 100 1200 420]);
base = 27.56640625;
u = @(v) (v - base) / 2^-48;               % position in units of 2^-48
hold on;
plot([-2.5 2.5], [0 0], "-", "color", GREY, "linewidth", 2);
for k = -2:2
  plot([k k], [-0.12 0.12], "-", "color", GREY, "linewidth", 2);
end
plot(0, 0, "o", "markersize", 18, "markerfacecolor", GREEN, "markeredgecolor", GREEN);
plot(1, 0, "o", "markersize", 18, "markerfacecolor", RED, "markeredgecolor", RED);
plot(-1, 0, "o", "markersize", 14, "markerfacecolor", [0.7 0.7 0.7], "markeredgecolor", [0.7 0.7 0.7]);
plot(-2, 0, "o", "markersize", 14, "markerfacecolor", [0.7 0.7 0.7], "markeredgecolor", [0.7 0.7 0.7]);
plot(2, 0, "o", "markersize", 14, "markerfacecolor", [0.7 0.7 0.7], "markeredgecolor", [0.7 0.7 0.7]);
text(0, 0.42, "27.56640625", "horizontalalignment", "center", "fontsize", 13);
text(0, 0.28, "(trailing fraction bits all 0)", "horizontalalignment", "center", "fontsize", 11, "color", GREY);
text(1, -0.35, "27.566406250000004", "horizontalalignment", "center", "fontsize", 13, "color", RED);
text(1, -0.5, "(the number in the notes: last bit = 1)", "horizontalalignment", "center", "fontsize", 11, "color", GREY);
plot([0 1], [0.12 0.12], "-", "color", ORANGE, "linewidth", 3);
text(0.5, 0.17, "gap = 2^{-48} = 3.55e-15", "horizontalalignment", "center", "fontsize", 12, "color", [0.75 0.4 0]);
axis([-2.5 2.5 -0.8 0.8]); set(gca, "ytick", [], "xtick", -2:2, ...
     "xticklabel", {"-2 ulp", "-1 ulp", "0", "+1 ulp", "+2 ulp"}); grid on;
title("Doubles near 27.56640625 are 3.55e-15 apart - nothing exists in between");
save_figure(fig, fullfile(out, "neighbouring-doubles-near-27-566.png"));

% ------------------------------------------------------------------ 4  exponent field map
fig = figure("visible", "off", "position", [100 100 1300 480]);
axes("position", [0.02 0.05 0.96 0.9]); hold on; axis([-8 108 -3.6 4]); axis off;
segs = [0 10; 10 90; 90 100];
cols = {[0.85 0.85 0.88], [0.76 0.85 0.96], [0.96 0.78 0.76]};
for s = 1:3
  rectangle("position", [segs(s, 1) 0 diff(segs(s, :)) 1.4], "facecolor", cols{s}, "edgecolor", [0.35 0.35 0.35]);
end
text(5, 0.7, "E = 0", "horizontalalignment", "center", "fontsize", 13, "fontweight", "bold");
text(50, 0.7, "E = 1 ... 2046     normal numbers", "horizontalalignment", "center", "fontsize", 15, "fontweight", "bold");
text(95, 0.7, "E = 2047", "horizontalalignment", "center", "fontsize", 13, "fontweight", "bold");
text(5, -0.7, "F = 0 : +/-0", "horizontalalignment", "center", "fontsize", 11);
text(5, -1.3, "F > 0 : subnormal", "horizontalalignment", "center", "fontsize", 11);
text(5, -2.0, "2^{-1074} ... 2.2e-308", "horizontalalignment", "center", "fontsize", 11, "color", GREY);
text(50, -0.7, "(-1)^S x 2^{E-1023} x (1 + F)", "horizontalalignment", "center", "fontsize", 14);
text(50, -1.5, "2.2250738585072014e-308  ...  1.7976931348623157e+308", "horizontalalignment", "center", "fontsize", 12, "color", GREY);
text(50, -2.2, "E = 1023 means exponent 0, so numbers in [1, 2) have E = 1023", "horizontalalignment", "center", "fontsize", 12, "color", GREY);
text(96, -0.7, "F = 0 : +/-Inf", "horizontalalignment", "center", "fontsize", 11);
text(96, -1.3, "F > 0 : NaN", "horizontalalignment", "center", "fontsize", 11);
text(50, 2.7, "What the 11-bit exponent field E means", "horizontalalignment", "center", "fontsize", 17, "fontweight", "bold");
text(50, 2.05, "The machine number in the notes has E = 1027, deep inside the normal range", "horizontalalignment", "center", "fontsize", 12, "color", GREY);
save_figure(fig, fullfile(out, "exponent-field-meaning.png"));

printf("Images written to %s\n", out);
