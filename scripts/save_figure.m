function save_figure(fig, filename, dpi)
% SAVE_FIGURE  Save a figure as PNG (works headless) and close it.
%
%   save_figure(fig, "images/plot.png")
%   save_figure(fig, "images/plot.png", 200)
%
%   With the gnuplot toolkit the anti-aliased "pngcairo" driver is used,
%   otherwise Octave's normal "png" driver.

  if nargin < 3
    dpi = 150;
  end
  if strcmp(graphics_toolkit(fig), "gnuplot")
    driver = "-dpngcairo";
  else
    driver = "-dpng";
  end
  print(fig, filename, driver, sprintf("-r%d", dpi));
  close(fig);
end
