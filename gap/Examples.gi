#
# Ugaly: Universal Groups Acting LocallY
#
# Implementations
#
##################################################################################################################

InstallMethod( gamma, "for d,a",
[IsInt, IsPerm],
function(d,a)
	local aut, lf;
	
	aut:=[];
	for lf in [1..d*(d-1)] do
		aut[lf]:=LeafOfAddress(d,2,OnTuples(AddressOfLeaf(d,2,lf),a));
	od;
	return PermList(aut);
end );

InstallMethod( gamma, "for l,d,a",
[IsInt, IsInt, IsPerm],
function(l,d,a)
	local aut, lf;
	
	if l<1 then
		Error("input argument l=",l," must be an integer greater than or equal to 1");
	elif l=1 then
		return a;
	else
		# l>=2
		aut:=[];
		for lf in [1..d*(d-1)^(l-1)] do
			aut[lf]:=LeafOfAddress(d,l,OnTuples(AddressOfLeaf(d,l,lf),a));
		od;
		return PermList(aut);
	fi;
end );

InstallMethod( gamma, "for l,d,s,addr",
[IsInt, IsInt, IsPerm, IsList],
function(l,d,s,addr)
	local aut, lf, addr_lf, i;

	if addr=[] then
		return gamma(l,d,s);
	else
		# addr is non-empty
		aut:=[];
		for lf in [1..d*(d-1)^(l-1)] do
			addr_lf:=AddressOfLeaf(d,l,lf);
			if IsMatchingSublist(addr_lf,addr) then
				for i in [Length(addr)..l] do addr_lf[i]:=addr_lf[i]^s; od;
			fi;
			Add(aut,LeafOfAddress(d,l,addr_lf));
		od;
		return PermList(aut);
	fi;
end );

InstallMethod( gamma, "for d,k,aut,z",
[IsInt, IsInt, IsPerm, IsMapping],
function(d,k,aut,z)
	local auts, dir;	
	
	auts:=[];
	for dir in [1..d] do Add(auts,Image(z,[aut,dir])); od;	
	return AssembleAutomorphism(d,k,auts);
end );

##################################################################################################################

InstallMethod( GAMMA, "for d,F",
[IsInt, IsPermGroup],
function(d,F)
	local a, gens;
	
	gens:=[];
	for a in GeneratorsOfGroup(F) do Add(gens,gamma(2,d,a)); od;
	return Group(gens);
end );

InstallMethod( GAMMA, "for l,d,F",
[IsInt, IsInt, IsPermGroup],
function(l,d,F)
	local a, gens;
	
	if l<1 then
		Error("input argument l=",l," must be an integer greater than or equal to 1");
	elif l=1 then
		return F;
	else
		gens:=[];
		for a in GeneratorsOfGroup(F) do Add(gens,gamma(l,d,a)); od;
		return Group(gens);
	fi;
end );

InstallMethod( GAMMA, "for d,k,F,z",
[IsInt, IsInt, IsPermGroup, IsMapping],
function(d,k,F,z)
	local gens, a, tuple, dir;
	
	gens:=[()];
	for a in GeneratorsOfGroup(F) do Add(gens,gamma(d,k,a,z)); od;
	return Group(gens);
end );

##################################################################################################################

InstallMethod( DELTA, "for d,F",
[IsInt, IsPermGroup],
function(d,F)
	local gens, trans, i, a, auts;
		
	# $\Delta(F)$
	gens:=[];
	# choose a transitivity set
	trans:=[];
	for i in [1..d] do Add(trans,RepresentativeAction(F,1,i)); od;		
	# F-section
	for a in GeneratorsOfGroup(F) do
		auts:=[];
		for i in [1..d] do Add(auts,trans[i]^(-1)*trans[i^a]); od;
		Add(gens,AssembleAutomorphism(d,1,auts));
	od;
	# kernel
	for a in GeneratorsOfGroup(Stabilizer(F,1)) do
		auts:=[];
		for i in [1..d] do Add(auts,a^trans[i]); od;
		Add(gens,AssembleAutomorphism(d,1,auts));
	od;
	return Group(gens);
end );

InstallMethod( DELTA, "for d,F,C",
[IsInt, IsPermGroup, IsPermGroup],
function(d,F,C)
	local gens, trans, i, a, gens_C, auts;

	# $\Delta(F,C)$
	if not IsCentral(Stabilizer(F,1),C) then
		Error("input argument C=",C," must be a central subgroup of Stabilizer(F,1)");
	else
		gens:=[];
		# choose a transitivity set
		trans:=[];
		for i in [1..d] do Add(trans,RepresentativeAction(F,1,i)); od;			
		# F-section
		for a in GeneratorsOfGroup(F) do Add(gens,gamma(d,a)); od;
		# kernel
		gens_C:=GeneratorsOfGroup(C);
		for a in gens_C do
			auts:=[];
			for i in [1..d] do Add(auts,a^trans[i]); od;
			Add(gens,AssembleAutomorphism(d,1,auts));
		od;
		return Group(gens);
	fi;
end );

##################################################################################################################

InstallMethod( PHI, "for d,F",
[IsInt, IsPermGroup],
function(d,F)
	local gens, a, addrs, gens_stabs, i, addr;

	gens:=[];
	# F-section: $\Gamma(F)$
	for a in GeneratorsOfGroup(F) do Add(gens,gamma(2,d,a)); od;
	# kernel
	for i in [1..d] do
		for a in GeneratorsOfGroup(Stabilizer(F,i)) do
			Add(gens,gamma(2,d,a,[i]));
		od;
	od;
	return Group(gens);
end );

InstallMethod( PHI, "for d,F,N",
[IsInt, IsPermGroup, IsPermGroup],
function(d,F,N)
	local gens, a, auts;

	# $\Phi(F,N)$
	if not IsTransitive(F,[1..d]) then
		Error("input argument F=",F," must be a transitive subgroup of SymmetricGroup(d=",d,")");
	elif not IsNormal(Stabilizer(F,1),N) then
		Error("input argument N=",N," must be a normal subgroup of Stabilizer(F,1)");
	else
		gens:=[];
		# F-section
		for a in GeneratorsOfGroup(F) do Add(gens,gamma(2,d,a)); od;
		# kernel (F can be assumed transitive)
		for a in GeneratorsOfGroup(N) do
			auts:=ListWithIdenticalEntries(d,());
			auts[1]:=a;
			Add(gens,AssembleAutomorphism(d,1,auts));
		od;
		return Group(gens);
	fi;
end );

InstallMethod( PHI, "for d,F,P",
[IsInt, IsPermGroup, IsList],
function(d,F,P)
	local gens, a, i, auts, j;

	# $\Phi(F,P)$
	if not IsDuplicateFree(Concatenation(P)) or not Union(P)=[1..d] then
		Error("input argument P=",P," must be a block system for F=",F,"\n");
	else
		gens:=[];
		# F-section
		for a in GeneratorsOfGroup(F) do Add(gens,gamma(2,d,a)); od;
		# kernel (not assuming F transitive)
		for i in [1..Length(P)] do
			for a in GeneratorsOfGroup(Stabilizer(F,P[i],OnTuples)) do
				auts:=[];
				for j in [1..d] do
					if j in P[i] then auts[j]:=a; else auts[j]:=(); fi;
				od;
				Add(gens,AssembleAutomorphism(d,1,auts));
			od;
		od;
		return Group(gens);
	fi;
end );

InstallMethod( PHI, "for d,k,F",
[IsInt, IsInt, IsPermGroup],
function(d,k,F)
	local gens, gens_F, comp_sets, dir, a, auts;

	# $\Phi_{k}(F)$
	gens:=[()];
	gens_F:=SmallGeneratingSet(F);
	# initialize compatibility sets of the identity
	comp_sets:=[];
	for dir in [1..d] do
		Add(comp_sets,CompatibilitySet(d,k,F,(),dir));
	od;
	# F-section
	for a in gens_F do
		auts:=[];
		for dir in [1..d] do Add(auts,CompatibleElement(d,k,F,a,dir)); od;
		Add(gens,AssembleAutomorphism(d,k,auts));
	od;
	# kernel
	for dir in [1..d] do
		for a in GeneratorsOfGroup(AsGroup(comp_sets[dir])) do
			auts:=ListWithIdenticalEntries(d,());
			auts[dir]:=a;
			Add(gens,AssembleAutomorphism(d,k,auts));
		od;		
	od;
	return Group(gens);
end );

InstallMethod( PHI, "for l,d,k,F",
[IsInt, IsInt, IsInt, IsPermGroup],
function(l,d,k,F)
	local gens, a, addrs, gens_stabs, addr, G, i;

	# $\Phi^{l}(F)$
	if k=1 then
		gens:=[];
		# subgroup $\Gamma(F)$
		for a in GeneratorsOfGroup(F) do Add(gens,gamma(l,d,a)); od;
		# initialize addresses and generators of stabilizers
		addrs:=Addresses(d,l-1);
		Remove(addrs,1);
		gens_stabs:=[];
		for i in [1..d] do
			Add(gens_stabs,ShallowCopy(GeneratorsOfGroup(Stabilizer(F,i))));
		od;
		# other generators
		for addr in addrs do
			for a in gens_stabs[addr[Length(addr)]] do
				Add(gens,gamma(l,d,a,addr));
			od;
		od;
		return Group(gens);
	else
		G:=F;
		for i in [k..l-1] do G:=PHI(d,i,G); od;
		return G;
	fi;
end );

InstallMethod( PHI, "for d,k,F,P",
[IsInt, IsInt, IsPermGroup, IsList],
function(d,k,F,P)
	local gens, gens_F, a, auts, i, r, dir;

	# $\Phi_{k}(F,P)
	if not IsDuplicateFree(Concatenation(P)) or not Union(P)=[1..d] then
		Error("input argument P=",P," must be a block system for $\\pi(F)$=",ImageOfProjection(d,k,F,1),"\n");
	else
		gens:=[];
		gens_F:=SmallGeneratingSet(F);
		# F-section
		for a in gens_F do
			auts:=ListWithIdenticalEntries(d,());
			for i in [1..Length(P)] do
				r:=Representative(CompatibilitySet(d,k,F,a,P[i]));
				for dir in P[i] do auts[dir]:=r; od;
			od;
			Add(gens,AssembleAutomorphism(d,k,auts));
		od;
		# kernel
		for i in [1..Length(P)] do
			for a in GeneratorsOfGroup(AsGroup(CompatibilitySet(d,k,F,(),P[i]))) do
				auts:=ListWithIdenticalEntries(d,());
				for dir in P[i] do auts[dir]:=a; od;
				Add(gens,AssembleAutomorphism(d,k,auts));
			od;		
		od;
		return Group(gens);
	fi;
end );

##################################################################################################################

InstallGlobalFunction( AbelianizationHomomorphism,
function(F)
	return NaturalHomomorphismByNormalSubgroup(F,DerivedSubgroup(F));
end );


##################################################################################################################

InstallGlobalFunction( SignHomomorphism,
function(F)
	return GroupHomomorphismByFunction(F,SymmetricGroup(2),
		function(g)
			if SignPerm(g)=-1 then
				return (1,2);
			else
				return ();
			fi;
		end);
end );

##################################################################################################################

InstallGlobalFunction( SpheresProduct,
function(d,k,aut,rho,R)
	local prod, addrs, addr;

	prod:=One(Range(rho));
	addrs:=Filtered(Addresses(d,k),addr->Length(addr) in R);
	for addr in addrs do
		prod:=prod*Image(rho,LocalAction(1,d,k,aut,addr));
	od;
	return prod;
end );

##################################################################################################################

InstallGlobalFunction( PI,
function(l,d,F,rho,R)
	local i, gens, G, A, indx, a;

	if R=[] then
		return PHI(l,d,1,F);
	elif R=[0] then
		return PHI(l,d,1,Kernel(rho));
	else
		# check point stabilizer surjectivity
		for i in [1..l] do
			if not IsSurjective(RestrictedMapping(rho,Stabilizer(F,i))) then
				Error("the map rho=",rho," must be surjective on all point stabilizers of F=",F);
			fi;
		od;
		# construction
		G:=PHI(l,d,1,F);
		A:=Range(rho);
		indx:=Size(A);
		gens:=[()];
		repeat
			a:=Random(G);
			if SpheresProduct(d,l,a,rho,R)=One(A) then Add(gens,a); fi;
		until Index(G,Group(gens))=indx;
	
		return Group(gens);
	fi;
end );

##################################################################################################################

InstallMethod( CompatibleKernels, "for d,F",
[IsInt, IsPermGroup],
function(d,F)
	local kernels, G, D, class, K, compatible, a, c, dir, c_dir;

	kernels:=[];
	G:=Kernel(RestrictedMapping(Projection(AutB(d,2)),PHI(d,F)));
	D:=GAMMA(d,F);
	for class in ConjugacyClassesSubgroups(G) do
		for K in class do
			compatible:=true;
			# normalizer condition
			for a in GeneratorsOfGroup(D) do
				if not K^a=K then compatible:=false; break; fi;
			od;
			if not compatible then continue; fi;
			# element condition
			for c in GeneratorsOfGroup(K) do
				for dir in [1..d] do
					compatible:=false;
					for c_dir in K do
						if LocalAction(1,d,2,c_dir,[dir])=LocalAction(1,d,2,c,[dir])^(-1) then
							compatible:=true;
							break;
						fi;
					od;
					if not compatible then break; fi;						
				od;
				if not compatible then break; fi;
			od;
			if compatible then Add(kernels,K); fi;
		od;
	od;
	return kernels;
end) ;

InstallMethod( CompatibleKernels, "for d,k,F,z",
[IsInt, IsInt, IsPermGroup, IsMapping],
function(d,k,F,z)
	local kernels, G, D, class, K, compatible, a, c, dir, c_dir;

	kernels:=[];	
	G:=Kernel(RestrictedMapping(Projection(AutB(d,k+1)),PHI(d,k,F)));
	D:=GAMMA(d,k,F,z);
	for class in ConjugacyClassesSubgroups(G) do
		for K in class do
			compatible:=true;
			# normalizer condition
			for a in GeneratorsOfGroup(D) do
				if not K^a=K then compatible:=false; break; fi;
			od;
			if not compatible then continue; fi;
			# element condition
			for c in GeneratorsOfGroup(K) do
				for dir in [1..d] do
					compatible:=false;
					for c_dir in K do
						if LocalAction(k,d,k+1,c_dir,[dir])=Image(z,[LocalAction(k,d,k+1,c,[dir]),dir])^(-1) then
							compatible:=true;
							break;
						fi;
					od;
					if not compatible then break; fi;						
				od;
				if not compatible then break; fi;
			od;
			if compatible then Add(kernels,K); fi;
		od;
	od;
	return kernels;
end );

##################################################################################################################

InstallMethod( SIGMA, "for d,F,K",
[IsInt, IsPermGroup, IsPermGroup],
function(d,F,K)
	local gens, a;

	gens:=[];
	for a in GeneratorsOfGroup(F) do Add(gens,gamma(d,a)); od;
	Append(gens,ShallowCopy(GeneratorsOfGroup(K)));
	return Group(gens);
end );

InstallMethod( SIGMA, "for d,k,F,K,z",
[IsInt, IsInt, IsPermGroup, IsPermGroup, IsMapping],
function(d,k,F,K,z)
	local gens, a;

	gens:=[];
	for a in GeneratorsOfGroup(F) do Add(gens,gamma(d,k,a,z)); od;
	Append(gens,ShallowCopy(GeneratorsOfGroup(K)));
	return Group(gens);
end );

