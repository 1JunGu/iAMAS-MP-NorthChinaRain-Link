procedure add_lc_labels(wks,map,minlat,maxlat,minlon,maxlon,\
                        lat_spacing[1]:integer,lon_spacing[1]:integer)
local lat_values, nlat, lat1_ndc, lat2_ndc, lon1_ndc, lon2_ndc,slope,txres, \
lon_values,  RAD_TO_DEG, dum_lft, dum_rgt, dum_bot
begin
  RAD_TO_DEG = get_r2d("double")

;---Pick some "nice" values for the latitude labels.
  minlat_ceil  = ceil(minlat/5.)*5
  maxlat_floor = floor(maxlat/5.)*5
  lat_values = ispan(toint(minlat_ceil),toint(maxlat_floor),lat_spacing) * 1.
  nlat       = dimsizes(lat_values)
;
; We need to get the slope of the left and right min/max longitude lines.
; Use NDC coordinates to do this.
;
  lat1_ndc = new(1,float)
  lon1_ndc = new(1,float)
  lat2_ndc = new(1,float)
  lon2_ndc = new(1,float)
  datatondc(map,minlon,lat_values(0),lon1_ndc,lat1_ndc)
  datatondc(map,minlon,lat_values(nlat-1),lon2_ndc,lat2_ndc)
  if(lon2_ndc.eq.lon1_ndc) then
      print("add_lc_labels: error: not enough valid latitude values to generate labels")
      print("    You may need to decrease the lat_spacing")
      exit
  end if
  slope_lft = (lat2_ndc-lat1_ndc)/(lon2_ndc-lon1_ndc)

  datatondc(map,maxlon,lat_values(0),lon1_ndc,lat1_ndc)
  datatondc(map,maxlon,lat_values(nlat-1),lon2_ndc,lat2_ndc)
  if(lat2_ndc.eq.lat1_ndc) then
      print("add_lc_labels: error: not enough valid longitude values to generate labels")
      print("    You may need to decrease the lon_spacing")
      exit
  end if
  slope_rgt = (lat2_ndc-lat1_ndc)/(lon2_ndc-lon1_ndc)

;---Set some text resources
  txres               = True
  txres@txFont = 25
  txres@txFontQuality = "High"
  txres@txFontHeightF = 0.03
  txres@txPosXF       = 0.1
;
; Loop through lat values, and attach labels to the left and
; right edges of the masked LC plot.  The labels will be 
; rotated to fit the line better.
;
  dum_lft = new(nlat,graphic)    ; Dummy array to hold attached strings.
  dum_rgt = new(nlat,graphic)    ; Dummy array to hold attached strings.
  do n=0,nlat-1
; Add extra white space to labels.
    lat_label_rgt = "          "  + lat_values(n) + "~S~o~N~"

;---Check if North, South, or Zero
    if(lat_values(n).lt.0) then
      lat_label_lft = lat_values(n) + "~S~o~N~S          "
      lat_label_rgt = lat_label_rgt + "S"
    end if
    if(lat_values(n).gt.0) then
      lat_label_lft = lat_values(n) + "~S~o~N~N          "
      lat_label_rgt = lat_label_rgt + "N"
    end if
    if(lat_values(n).eq.0) then
      lat_label_lft = lat_values(n) + "~S~o~N~           "
    end if

;---Left label
    txres@txAngleF = RAD_TO_DEG * atan(slope_lft) - 90
    dum_lft(n) = gsn_add_text(wks,map,lat_label_lft,minlon,lat_values(n),txres)

;---Right label
    ;txres@txAngleF = RAD_TO_DEG * atan(slope_rgt) + 90
    ;dum_rgt(n) = gsn_add_text(wks,map,lat_label_rgt,maxlon,lat_values(n),txres)
  end do

;----------------------------------------------------------------------
; Now do longitude labels. These are harder because we're not
; adding them to a straight line.
;
; Loop through lon values, and attach labels to the bottom edge of the
; masked LC plot.
;
  delete(txres@txPosXF)
  txres@txPosYF = -5.0

;---Pick some "nice" values for the longitude labels.
  lon_values = ispan(toint(minlon)+5,toint(maxlon)-5,lon_spacing) * 1.
  nlon       = dimsizes(lon_values)

  dum_bot = new(nlon,graphic)    ; Dummy array to hold attached strings.

  do n=0,nlon-1
;
; For each longitude label, we need to figure out how much to rotate
; it, so get the approximate slope at that point.
;
    datatondc(map,lon_values(n)-0.25,minlat,lon1_ndc,lat1_ndc)
    datatondc(map,lon_values(n)+0.25,minlat,lon2_ndc,lat2_ndc)
    slope_bot = (lat1_ndc-lat2_ndc)/(lon1_ndc-lon2_ndc)
    txres@txAngleF  = atan(slope_bot) * RAD_TO_DEG
;
; Create longitude label. Add extra carriage returns to
; move label away from plot.
;
;---Check if East, West, or Zero
    lon_label_bot = "  ~C~  ~C~" + abs(lon_values(n)) + "~S~o~N~"
    if(lon_values(n).lt.0) then
      lon_label_bot = lon_label_bot + "W"
    end if
    if(lon_values(n).gt.0) then
      lon_label_bot = lon_label_bot + "E"
    end if

;---Attach to map.
    dum_bot(n) = gsn_add_text(wks,map,lon_label_bot,lon_values(n),minlat,txres)
  end do
end
begin
    print_clock("start")
;---read simulations 
    rain_sim = new((/4,785410/),double)
    data_path = "../../data/simulation/0728_12/"
    case_list = (/"RM_THQ","RM_Q","RM_T","RM_T_MP"/)
    do icase = 0, 2
        fi_rain = addfile(data_path + case_list(icase) +  "/rain_hr.nc","r")
        rain_sim(icase,:) = fi_rain->rain_hr*72
    end do
    fi_rain = addfile(data_path + case_list(3) +  "/rain_mpas.nc","r")
    rain_sim(3,:) = fi_rain->rain_3day
    static_fi = addfile(data_path + "../cell_fill.nc","r")
    latCell = static_fi->latCell
    lonCell = static_fi->lonCell
    latvoc  = static_fi->latvoc
    lonvoc  = static_fi->lonvoc

    ;minlat = 31
    ;maxlat = 43
    ;minlon = 107
    ;maxlon = 122
    minlat = 28
    maxlat = 45
    minlon = 105
    maxlon = 130

    N_res = 4
    wks_type = "png"
    wks_type@wkWidth  = 1024*N_res;
    wks_type@wkHeight = 1024*N_res
    wks = gsn_open_wks(wks_type, "./FigureS3")

    ;rain_cnlevels = (/0.1, 1, 5, 10, 25., 50,75, 100.,150,200,300,400,500,600,700/);16 colors
    ;rain_cmap = read_colormap_file("precip2_17lev")
    ;rain_colors = new((/16,4/),float)
    ;rain_colors(0,:) = rain_cmap(0,:)
    ;rain_colors(1:15,:) = rain_cmap(2:16,:)

    rain_cnlevels = (/0.1, 1, 5, 10, 25., 50,75, 100.,150,200,300,400,500,600/);16 colors
    rain_cmap = read_colormap_file("precip2_17lev")
    rain_colors = new((/15,4/),float)
    rain_colors(0,:) = rain_cmap(0,:)
    rain_colors(1:14,:) = rain_cmap(3:16,:)

    res = True
    res@gsnDraw = False
    res@gsnFrame= False
    res@gsnAddCyclic = False
    res@gsnMaximize  = True
    ;res@gsnStringFont = 25
    res@gsnRightString  = ""
    res@gsnLeftStringFontHeightF = 0.022
    res@gsnLeftStringOrthogonalPosF = 0.035
    ;res@gsnRightStringOrthogonalPosF = 0.02

    ;lres@vpHeightF = 0.8
    ;lres@vpWidthF  = 0.8
    ;lres@vpXF = 0.1
    ;lres@vpYF = 0.95

    mpres = res
    mpres@mpProjection = "LambertConformal"
    mpres@mpLambertParallel1F = 35
    mpres@mpLambertParallel2F = 45
    mpres@mpLambertMeridianF = 117.5

    mpres@mpLimitMode   	= "LatLon"
    mpres@mpMinLatF = minlat
    mpres@mpMaxLatF = maxlat
    mpres@mpMinLonF = minlon
    mpres@mpMaxLonF = maxlon
    mpres@gsnMaskLambertConformal = True
    mpres@gsnMaskLambertConformalOutlineOn = False

    mpres@mpDataSetName     = "$HOME/.config/NCL/database/Earth..4"
    mpres@mpDataBaseVersion        = "MediumRes"
    ;mpres@mpAreaMaskingOn = True
    mpres@mpOutlineSpecifiers        = (/"China","China:Provinces"/)
    mpres@mpLandFillColor            = "white"
    mpres@mpInlandWaterFillColor     = "white"
    mpres@mpOceanFillColor           = "white"
    mpres@mpFillBoundarySets         = "NoBoundaries"
    mpres@mpOutlineBoundarySets      = "Geophysical"
    mpres@mpNationalLineColor        = "black"
    mpres@mpProvincialLineColor      = "black"
    mpres@mpGeophysicalLineColor     = "black"
    mpres@mpNationalLineThicknessF   = 4*N_res
    mpres@mpProvincialLineThicknessF = 2*N_res
    mpres@mpGeophysicalLineThicknessF = 2*N_res

    mpres@mpGridAndLimbOn       = True
    mpres@mpGridSpacingF        = 5.0
    mpres@mpGridLineDashPattern = 2
    mpres@mpGridLineThicknessF  = 1.5*N_res

    ;mpres@pmTickMarkDisplayMode = "Always"
    mpres@tmXTOn = False
    mpres@tmYROn = False
    mpres@tmBorderThicknessF = 4.5*N_res
    mpres@tmYLMajorThicknessF = 3.5*N_res
    mpres@tmYLMinorThicknessF = 3.5*N_res
    mpres@tmYLMajorLengthF    = 0.01
    mpres@tmYLMinorLengthF    = 0.006
    mpres@tmXBMajorThicknessF = 3.5*N_res
    mpres@tmXBMinorThicknessF = 3.5*N_res
    mpres@tmXBMajorLengthF    = 0.01
    mpres@tmXBMinorLengthF    = 0.006
    mpres@tmXBLabelFont = 25
    mpres@tmYLLabelFont = 25

    mpres@tmXBMinorOn = True
    mpres@tmYLMinorOn = True
    ;mpres@tmXBLabelDeltaF = -0.5
    ;mpres@tmYLLabelDeltaF = -0.5
    mpres@tmXBLabelFontHeightF = 0.017
    mpres@tmYLLabelFontHeightF = 0.017

    ;mpres@tmXBMode = "Explicit"
    ;mpres@tmXBValues = fspan(105,125,5)
    ;mpres@tmXBLabels = mpres@tmXBValues + "~S~o~N~E"
    ;mpres@tmXBMinorValues = ispan(105,129,1)

    ;mpres@tmYLMode = "Explicit"
    ;mpres@tmYLValues = fspan(30,45,4)
    ;mpres@tmYLLabels = mpres@tmYLValues + "~S~o~N~N"
    ;mpres@tmYLMinorValues = ispan(26,45,1)

    ;-------Plot---------
    plot = new(4,graphic)
    Leftstring_list = (/"a ", "b ", "c ", "d "/)

    shres = res
    shres@cnFillDrawOrder = "PostDraw"
    shres@cnFillOn  = True
    shres@cnLinesOn = False
    shres@cnInfoLabelOn   = False
    shres@cnLevelSelectionMode = "ExplicitLevels"
    shres@cnLevels = (/588/)*10
    sh_colors = (/(/0,0,0,0/),(/178/255.,34/255.,34/255.,0.7/)/)
    shres@cnFillColors = sh_colors
    shres@lbLabelBarOn = False

    sdres = mpres
    sdres@cnFillDrawOrder = "Draw"
    sdres@cnFillOn = True
    sdres@cnLinesOn = False
    sdres@cnInfoLabelOn   = False
    sdres@cnLineLabelsOn  = False

    sdres@cnFillMode = "RasterFill"
    sdres@cnRasterSmoothingOn = True

    sdres@cnLevelSelectionMode = "ExplicitLevels"
    sd_cnlevels = fspan(-5,5,51)
    sd_cmap =  read_colormap_file("MPL_RdBu")
    sd_colors = new((/52,4/),"float")
    sd_colors = sd_cmap(12:114:-2,:)
    sdres@cnLevels        = sd_cnlevels
    sdres@cnFillColors    = sd_colors
    sdres@lbLabelBarOn    = False

    vcres                       = res
    vcres@vcGlyphStyle          = "LineArrow"
    ;vcres@vcGlyphStyle          = "CurlyVector"
    vcres@vcRefLengthF          = 0.03
    vcres@vcLineArrowColor      = "Black"
    vcres@vcMinDistanceF        = 0.023          ; set to small value to thin the vectors.
    vcres@vcLineArrowThicknessF = 3.            ; make the vectors thicker.
    vcres@vcVectorDrawOrder     = "PostDraw"

    vcres@vcRefAnnoOn               = True
    vcres@vcRefMagnitudeF           = 50.0
    vcres@vcRefAnnoString1          = "~F25~50"
    vcres@vcRefLengthF              = 0.03   ; define length of vec ref
    vcres@vcRefAnnoFontHeightF      = 0.02
    vcres@vcRefAnnoFontThicknessF   = 1.
    vcres@vcRefAnnoSide             = "Bottom"
    ;vcres@vcRefAnnoJust             = "TopLeft"
    vcres@vcRefAnnoString2On        = False
    vcres@vcRefAnnoPerimOn          = False
    vcres@vcRefAnnoOrthogonalPosF   = 0
    vcres@vcRefAnnoParallelPosF     = 0.99
    vcres@vcRefAnnoBackgroundColor  = "white"

    cnres = mpres
    cnres@cnFillDrawOrder = "Draw"
    cnres@cnFillOn = True
    cnres@cnLinesOn = False
    cnres@cnInfoLabelOn   = False
    cnres@cnLineLabelsOn  = False

    cnres@cnFillMode = "RasterFill"

    cnres@cnLevelSelectionMode = "ExplicitLevels"
    cnres@cnLevels        = rain_cnlevels
    cnres@cnFillColors    = rain_colors
    cnres@lbLabelBarOn    = False
    do icase =0,3
            cnres@gsnLeftString = "~F26~" + Leftstring_list(icase) + case_list(icase)
            ;cnres@cnRasterSmoothingOn = True
            cnres@trGridType = "TriangularMesh"
            cnres@sfXArray := lonCell
            cnres@sfYArray := latCell
            ;cnres@sfXCellBounds = lonvoc
            ;cnres@sfYCellBounds = latvoc
            plot(icase) = gsn_csm_contour_map(wks,rain_sim(icase,:),cnres)
    end do

    box_lat = (/35,35,41,41,35/)
    box_lon = (/112.5,117.5,117.5,112.5,112.5/)
    box = new(4,graphic)
    plres   = True
    plres@gsLineDashPattern = 0
    plres@gsLineThicknessF  = 10
    plres@gsLineColor = "Black"
    do icase =0,3
        lat_spacing  = 5
        lon_spacing  = 5
        add_lc_labels(wks,plot(icase),minlat,maxlat,minlon,maxlon,lat_spacing,lon_spacing)
        box(icase) = gsn_add_polyline(wks, plot(icase), box_lon, box_lat, plres)
    end do

;Create common label
    lbres = True
    lbres@vpXF = 0.23
    lbres@vpYF = 0.05
    lbres@vpWidthF = 0.54
    lbres@vpHeightF= 0.05

    lbres@lbPerimOn = False
    lbres@lbBoxLinesOn = True
    lbres@lbBoxLineThicknessF = 4.0*N_res
    lbres@lbBoxSeparatorLinesOn = False
    lbres@lbOrientation = "Horizontal"
    lbres@lbFillColors  := rain_colors
    lbres@lbMonoFillPattern = True
    lbres@lbLabelFontHeightF = 0.012
    lbres@lbLabelAlignment   = "InteriorEdges"
    lbres@lbTitleJust = "TopCenter"
    lbres@lbTitleOffsetF = 0.2
    lbres@lbTitleExtentF = 0.25
    lbres@lbTitleFontHeightF = 0.014
    lbres@lbTitleString = "~F25~3-day accumulated precipitation (mm)";optional
    lbres@lbTitlePosition = "Bottom"
    lbres@lbLabelStride = 1
    nboxes := dimsizes(rain_colors)
    labels := "~F25~"+rain_cnlevels
    lbid_rain = gsn_create_labelbar(wks,nboxes,labels,lbres)
    draw(lbid_rain)


    resP = True
    resP@gsnPanelLabelBar = False
    resP@gsnMaximize = True
    resP@gsnPanelRowSpec = True
    resP@gsnPanelCenter = True
    resP@gsnPanelYWhiteSpacePercent = 2
    resP@gsnPanelBottom = 0.06
    ;resP@gsnPanelDebug = True
    ;drawNDCGrid(wks)
    gsn_panel(wks,plot,(/2,2/),resP)
    print_clock("End")
end
