{
  chromexup-src,
  pkgs,
  python3Packages,
}:
pkgs.python3Packages.buildPythonApplication {
  pname = "chromexup";
  version = "unstable"; # Use 'unstable' as there is no version in the repo
  src = chromexup-src;
  propagatedBuildInputs = with pkgs.python3Packages; [requests];
  build-system = with python3Packages; [setuptools];
  pyproject = true;
  # You may need to add more Python dependencies depending on the actual needs
  # You could also override 'doCheck' and other attributes as required
}
