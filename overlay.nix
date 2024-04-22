{ chromexup-src } : (self: super: {
  chromexup = super.python3Packages.buildPythonApplication {
    pname = "chromexup";
    version = "unstable"; # Use 'unstable' as there is no version in the repo
    src = chromexup-src;
    propagatedBuildInputs = with super.python3Packages; [ requests ];
    # You may need to add more Python dependencies depending on the actual needs
    # You could also override 'doCheck' and other attributes as required
  };
})