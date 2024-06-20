begin
    dq = str_get_dq()
    date_cmd   = "date +" + dq + "%a %b %d %H:%M:%S %Z %Y" + dq
    wcStrt = systemfunc(date_cmd)
;---Processing----------------
    f = addfile("/storage/aemolcore02/jungu/mesh/rotated_4-60km_28N117E_785410/init_static.nc","r")
    r2d = get_r2d("double")             ; radians to degrees

    lonCell   = f->lonCell(:) * r2d
    latCell   = f->latCell(:) * r2d
    lonVertex = f->lonVertex(:) * r2d
    latVertex = f->latVertex(:) * r2d
    lonEdge = f->lonEdge(:) * r2d
    latEdge = f->latEdge(:) * r2d
    verticesOnCell = f->verticesOnCell(:,:)
    verticesOnEdge = f->verticesOnEdge(:,:)
    nEdgesOnCell   = f->nEdgesOnCell;(nCells)

    ;derive lat/lon of vertices of cells
    dims = dimsizes(verticesOnCell)
    nCells   = dims(0)
    maxEdges = dims(1)
    latvoc = new((/nCells,maxEdges/), double, -999.) ;latitude Vertex of Cells
    lonvoc = new((/nCells,maxEdges/), double, -999.)
    system("echo nCells:" + nCells + " maxEdges: " + maxEdges)
    system("echo minmax verticesOnCell")
    printMinMax(verticesOnCell,1)
    system("echo minmax verticesOnEdge")
    printMinMax(verticesOnEdge,1)
    print(dimsizes(latVertex))

    verticesOnCell@_FillValue = 0
    do i=0, maxEdges-1
        latvoc(:,i) = latVertex(verticesOnCell(:,i) - 1)
        lonvoc(:,i) = lonVertex(verticesOnCell(:,i) - 1)
    end do

    ;---For polygons that don't use the full maxEdges, fill in the rest of them.
    ii = ind(nEdgesOnCell.lt.maxEdges)
    do i = 0, nCells - 1
        latvoc(ii(i), nEdgesOnCell(ii(i)):maxEdges-1 ) = latvoc(ii(i),nEdgesOnCell(ii(i))-1)
        lonvoc(ii(i), nEdgesOnCell(ii(i)):maxEdges-1 ) = lonvoc(ii(i),nEdgesOnCell(ii(i))-1)
    end do

    a= get_sphere_radius()
    ;dcEdge = f->dcEdge(:)*a  ;for grid.nc
    dcEdge = f->dcEdge(:)  ;for static.nc
  
    print ("Max. distance of cell to cell -->> "+max(dcEdge))
    print ("Min. distance of cell to cell -->> "+min(dcEdge))
  
    nCells=dimsizes(lonCell)
    avg_dist=new((/nCells/), double)
    avg_dist@_FillValue = -9999.0
  
    nEdgesOnCell = f->nEdgesOnCell(:)
    EdgesOnCell  = f->edgesOnCell(:,:)
  
    do iCell=0,nCells-1
      distance = 0.D
      do iEdge = 0, nEdgesOnCell(iCell)-1
        jEdge = EdgesOnCell(iCell,iEdge)-1
        distance = distance + dcEdge(jEdge)
      end do
      avg_dist(iCell) = distance/(nEdgesOnCell(iCell))/1000.
    end do 
  
    wallClockElapseTime(wcStrt, "Processing", 0)
;-----------------------------
    wcStrtGraphics = systemfunc(date_cmd)
    wks_name = "FigureS1"
    wks_type = "png"
    N_res = 3
    wks_type@wkHeight = 1024*N_res
    wks_type@wkWidth  = 1024*N_res
    wks = gsn_open_wks(wks_type, wks_name)
  

    ;set uniform resources
    res = True
    res@gsnDraw = False
    res@gsnFrame= False
    ;res@gsnAddCyclic = False
    res@gsnMaximize  = False
    res@gsnStringFont = 25
    res@gsnStringFontHeightF = 0.019
    res@gsnLeftString = ""
    res@gsnRightString= ""
    res@gsnLeftStringOrthogonalPosF =  0.01
    res@gsnRightStringOrthogonalPosF = 0.02
  
    res@mpProjection      = "Satellite"
    res@mpSatelliteDistF  = 1.4
    res@mpSatelliteAngle1F = 0
    res@mpDataSetName     = "/storage/aemolcore02/jungu/Data/Earth..4/Earth..4"
    res@mpDataBaseVersion = "MediumRes"
    res@mpCenterLatF      = 28;30.4;32.
    res@mpCenterLonF      = 117;118.5;120.
    res@mpCenterRotF      = 0.
    res@mpGridAndLimbOn   = False ;longitude & latitude grids on/off 
    res@mpFillOn          = True 
    res@mpPerimOn         = False
    res@mpOutlineOn           = True
    res@mpOutlineBoundarySets = "National"
    res@mpOutlineSpecifiers        = (/"China","China:Provinces"/)
    res@mpNationalLineColor        = "black"
    res@mpProvincialLineColor      = "black"
    res@mpGeophysicalLineColor     = "black"
    res@mpGeophysicalLineThicknessF= 1*N_res
    res@mpNationalLineThicknessF   = 1*N_res
    res@mpProvincialLineThicknessF = 1*N_res
  
  
    ;if (any(isnan_ieee(avg_dist))) then
    ;    replace_ieeenan(avg_dist, avg_dist@_FillValue, 0)
    ;end if
    avg_dist@_FillValue = -9999.0
    print(num(ismissing(avg_dist)))
    avg_dist = where(avg_dist.lt.60, avg_dist, 60)
  
    print ("Max. avg. distance of cell to cell -->> "+max(avg_dist))
    print ("Min. avg. distance of cell to cell -->> "+min(avg_dist))
  
    res@gsnSpreadColors   = True
    res@cnFillOn          = True
    res@cnFillMode        = "CellFill"
    ;res@cnRasterSmoothingOn = True
    res@cnLinesOn         = False
    res@cnLineLabelsOn    = False
    res@cnInfoLabelOn     = False
    res@sfXArray = lonCell
    res@sfYArray = latCell
    res@sfXCellBounds = lonvoc
    res@sfYCellBounds = latvoc
  
    ;res@cnFillColors = (/20,55,75,100,120,145,165,205/)
    ;res@cnLevels     = (/3,5,7,10,15,20,25/)
    ;res@cnLevels     = (/10,20,30,50,60,80,120/);16-128km
    ;res@lbLabelStrings=(/" "," "," "," "," "/)
    ;cnlevels = fspan(0.5,20,40)
    ;print(cnlevels)
    rain_cmap = read_colormap_file("WhiteBlueGreenYellowRed")
    colors = rain_cmap((/0,20,45,70,95,120,140,145,165,180/),:)
    ncolors = dimsizes(colors)
    colors((/7,8,9/),3) = 0.8
    cnlevels = (/2,6,10,15,20,25,30,40,55/)


    res@cnLevelSelectionMode    = "ExplicitLevels"
    res@cnLevels     = cnlevels
    res@cnFillColors = colors
    res@lbLabelBarOn    = False

    plot= gsn_csm_contour_map(wks,avg_dist,res)
	
    lnres=True
    lnres@gsLineColor = "navyblue"
    lnres@gsLineDashPattern = 1
    lnres@gsLineThicknessF = 5.0*N_res
    
    
    cen_lat = 28
    cen_lon = 117
    circle1    = geolocation_circle(cen_lat, cen_lon, 14.5, 0, 180, False) ;v16
    circle_lat1 = circle1[0]                   ; For clarity: explicitly extract list elements
    circle_lon1 = circle1[1]

    dum1 = gsn_add_polyline(wks, plot, circle_lon1(0,0,:), circle_lat1(0,0,:), lnres)
    circle2    = geolocation_circle(cen_lat, cen_lon, 34, 0, 180, False)
    circle_lat2 = circle2[0]                   ; For clarity: explicitly extract list elements
    circle_lon2 = circle2[1]
    
    lnres@gsLineColor = "White"
    dum2 = gsn_add_polyline(wks, plot, circle_lon2(0,0,:), circle_lat2(0,0,:), lnres)

    ;Create common label
    lbres = True
    lbres@vpXF = 0.2
    lbres@vpYF = 0.145
    ;lbres@vpYF = 0.30
    lbres@vpWidthF = 0.6
    lbres@vpHeightF= 0.07
    lbres@lbPerimOn = False
    lbres@lbBoxLinesOn = True
    lbres@lbBoxSeparatorLinesOn = False
    lbres@lbBoxLineThicknessF = 1.2*N_res
    lbres@lbFillColors  := colors
    lbres@lbOrientation = "horizontal"
    lbres@lbMonoFillPattern = True
    lbres@lbLabelFontHeightF = 0.016
    lbres@lbLabelAlignment   = "InteriorEdges"
    lbres@lbTitlePosition = "Bottom"
    lbres@lbTitleFontHeightF = 0.019
    lbres@lbTitleOffsetF = 0.2
    lbres@lbTitleExtentF = 0.25
    lbres@lbTitleString = "Mesh size (km)";optional
    lbres@lbTitleFont = 25
    lbres@lbLabelStride = 1
    nboxes := dimsizes(colors)
    labels := "~F25~"+cnlevels
    lbid = gsn_create_labelbar(wks,nboxes,labels,lbres)
    draw(lbid)

  
    draw(plot)
    frame(wks)
  
end

