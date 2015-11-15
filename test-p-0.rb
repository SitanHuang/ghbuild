if `which ghbuild` =~ /.+no ghbuild.+/
	error "\tNo ghbuild executable found\n"
else
	log "\tghbuild executable found\n"
end
