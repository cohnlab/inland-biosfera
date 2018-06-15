;gabriel abrahao - gabriel.abrahao@ufv.br 
;Interpolates soil levels
;Currently it does not exactly interpolate, but instead pick values on the closest layer

begin
;infname             =   "../../input/soita.sand.nc"
;varname               =   "sandpct"
;outfname            =   "soita.sand.nc"
 infname             =   "../../input/soita.clay.nc"
 varname               =   "claypct"
 outfname            =   "soita.clay.nc"

;Layer heights (downward) to interpolate to
newhsoi =   (/0.05,0.05,0.10,0.10,0.10,0.10,0.20,0.20,0.50,0.50,0.50/)*100 ;The metadata is in centimeters
newnlay = dimsizes(newhsoi)


arqinvar = addfile(infname,"r")
invar = arqinvar->$varname$

printVarSummary(invar)
oldlay = invar&layer
oldnlay = dimsizes(oldlay)


newlay = new(newnlay,typeof(oldlay))

;Accumulate heights to get layer depths
newlay(0) = newhsoi(0)
do i = 1,newnlay-1
    newlay(i) = newlay(i-1) + newhsoi(i)
end do

;Create output array
indims = dimsizes(invar)
outdims = indims
outdims(1) = newnlay
outvar = new(outdims,typeof(invar))
copy_VarAtts(invar, outvar)
outvar!0 = invar!0
outvar!1 = invar!1
outvar!2 = invar!2
outvar!3 = invar!3

outvar&$outvar!0$ = invar&$invar!0$
outvar&$outvar!1$ = newlay
outvar&$outvar!2$ = invar&$invar!2$
outvar&$outvar!3$ = invar&$invar!3$



;Get the value at equivalent depths
do i = 0,newnlay-1
    do j = 0,oldnlay-1
        if (newlay(i).le.oldlay(j)) then 
            outvar(:,i,:,:) = (/invar(:,j,:,:)/) ;The array notation is needed to ignore the coordinates from invar
            break
        end if
    end do
end do

;Really wont hurt to have missing values properly set 
outvar = where((outvar.ge.0).and.(outvar.le.100),outvar,outvar@_FillValue)


system("[ -e "+outfname+" ] && rm "+outfname)
arqout = addfile(outfname,"c")
arqout->$varname$ = outvar

end