  { config, pkgs, ... }:{
  
  
  environment.systemPackages =   
	  let 
		  offtree = import ../pkgs/default.nix;
	  in [
		  #offtree.sunvox
		  #offtree.pixilang
		  #offtree.ocenaudio
	  ];
	  
  
  }