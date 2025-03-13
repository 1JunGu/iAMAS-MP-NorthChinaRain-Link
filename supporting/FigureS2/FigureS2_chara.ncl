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
  txres@txFontHeightF = 0.015
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
;---read circulations of ERA5 for plot a
    ERA5_data_path = "/work/home/jungu/Work/iAMAS-237-Rainstorm-paper/data/reanalysis/ERA5/"
    zuvq_fi = addfile(ERA5_data_path + "zuvq.nc","r")

    z_s = dim_avg_n_Wrap(zuvq_fi->z(:,0,:,:),0)
    u_s = dim_avg_n_Wrap(zuvq_fi->u(:,0,:,:),0)
    v_s = dim_avg_n_Wrap(zuvq_fi->v(:,0,:,:),0)
    q_s = dim_avg_n_Wrap(zuvq_fi->q(:,0,:,:),0)
    ;printMinMax(q_s,1)

    g = 9.80665
    height_ERA5 = z_s/g
    copy_VarCoords(z_s, height_ERA5)
    ;calculate moisture flux
    qu_ERA5 = q_s*u_s*1e3
    qv_ERA5 = q_s*v_s*1e3
    copy_VarCoords(z_s, qu_ERA5)
    copy_VarCoords(z_s, qv_ERA5)

    w_fi = addfile(ERA5_data_path + "w.nc","r")
    w_ERA5 = dim_avg_n_Wrap(w_fi->w(:,1,:,:),0)
    copy_VarCoords(z_s, w_ERA5)
    printMinMax(w_ERA5,1)
    ;w_s = w_s*1e1
;--- read circulations of MPAS for plot b
    Re = get_sphere_radius()
    MPAS_data_path = "/work/home/jungu/Work/iAMAS-237-Rainstorm-paper/data/simulation/0728_12/CTL/ERA5/"
    height_fi = addfile(MPAS_data_path + "height.nc","r")
    nLevels = height_fi->nLevels
    ind_500hPa = ind(nLevels.eq.50000)
    height_ctl = height_fi->height(ind_500hPa,:,:)

    uReconstructZonal_fi = addfile(MPAS_data_path + "uReconstructZonal.nc","r")
    uzonal = uReconstructZonal_fi->uReconstructZonal(ind_500hPa,:,:)
    uReconstructMeridional_fi = addfile(MPAS_data_path + "uReconstructMeridional.nc","r")
    umeridional = uReconstructMeridional_fi->uReconstructMeridional(ind_500hPa,:,:)

    q_fi = addfile(MPAS_data_path + "qv.nc","r")
    q_ctl = q_fi->qv(ind_500hPa,:,:)

    qu_ctl = uzonal*q_ctl*1e3
    qv_ctl = umeridional*q_ctl*1e3
    copy_VarCoords(height_ctl, qu_ctl)
    copy_VarCoords(height_ctl, qv_ctl)

    height_ctl = Re*height_ctl/(Re + height_ctl)
    copy_VarCoords(qu_ctl, height_ctl)

    vertical_fi = addfile(MPAS_data_path + "../w_isobaric.nc","r")
    w_ctl = vertical_fi->w(:,ind_500hPa)
    v4km_fi = addfile("/storage/aemolcore02/jungu/mesh/rotated_4-60km_28N117E_785410/cell_fill.nc","r")
    latCell = v4km_fi->latCell
    lonCell = v4km_fi->lonCell
    printMinMax(w_ctl,1)

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
    wks = gsn_open_wks(wks_type, "./FigureS2")

    res = True
    res@gsnDraw = False
    res@gsnFrame= False
    res@gsnAddCyclic = False
    res@gsnMaximize  = False
    res@gsnStringFont = 25
    res@gsnRightString  = ""
    res@gsnLeftStringFontHeightF = 0.015
    ;res@gsnLeftStringOrthogonalPosF = 0.035
    ;res@gsnRightStringOrthogonalPosF = 0.02

    res@vpHeightF = 0.8
    res@vpWidthF  = 0.8
    res@vpXF = 0.1
    res@vpYF = 0.9

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

    mpres@mpDataSetName            = "/storage/aemolcore02/jungu/Data/Earth..4/Earth..4"
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
    mpres@tmXBLabelFontHeightF = 0.014
    mpres@tmYLLabelFontHeightF = 0.014

    ;mpres@tmXBMode = "Explicit"
    ;mpres@tmXBValues = fspan(105,125,5)
    ;mpres@tmXBLabels = mpres@tmXBValues + "~S~o~N~E"
    ;mpres@tmXBMinorValues = ispan(105,129,1)

    ;mpres@tmYLMode = "Explicit"
    ;mpres@tmYLValues = fspan(30,45,4)
    ;mpres@tmYLLabels = mpres@tmYLValues + "~S~o~N~N"
    ;mpres@tmYLMinorValues = ispan(26,45,1)

    shres = res
    shres@cnFillDrawOrder = "PostDraw"
    shres@cnFillOn  = True
    shres@cnLinesOn = False
    shres@cnInfoLabelOn   = False
    shres@cnLineLabelsOn = False
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
    sd_cnlevels = fspan(-0.1,0.1,51)
    sd_cmap =  read_colormap_file("MPL_RdBu")
    sd_colors = new((/52,4/),"float")
    ;sd_colors = sd_cmap(12:114:-2,:)
    sd_colors = sd_cmap(12:114:2,:)
    sdres@cnLevels        = sd_cnlevels
    sdres@cnFillColors    = sd_colors
    sdres@lbLabelBarOn    = False

    vcres                       = res
    vcres@vcGlyphStyle          = "LineArrow"
    ;vcres@vcGlyphStyle          = "CurlyVector"
    vcres@vcRefLengthF          = 0.03
    vcres@vcLineArrowColor      = "Black"
    vcres@vcMinDistanceF        = 0.023          ; set to small value to thin the vectors.
    vcres@vcLineArrowThicknessF = 2.*N_res            ; make the vectors thicker.
    vcres@vcVectorDrawOrder     = "PostDraw"

    vcres@vcRefAnnoOn               = True
    vcres@vcRefMagnitudeF           = 50.0
    vcres@vcRefAnnoString1          = "~F25~50"
    vcres@vcRefAnnoString2On        = True
    vcres@vcRefAnnoString2          = "~F25~g/kg m/s"
    vcres@vcRefLengthF              = 0.03   ; define length of vec ref
    vcres@vcRefAnnoFontHeightF      = 0.01
    vcres@vcRefAnnoFontThicknessF   = 1.
    vcres@vcRefAnnoSide             = "Bottom"
    ;vcres@vcRefAnnoJust             = "TopLeft"
    vcres@vcRefAnnoPerimOn          = False
    vcres@vcRefAnnoOrthogonalPosF   = 0
    vcres@vcRefAnnoParallelPosF     = 0.99
    vcres@vcRefAnnoBackgroundColor  = "white"

    ;sdres@gsnLeftString = "500-hPa moisture flux and vertical speed"
    sdres@gsnLeftString = "a ERA5"
    sdres@gsnLeftStringOrthogonalPosF = 0.05
    sdres@gsnLeftStringFontHeightF = 0.022
    sdres@gsnStringFont = 26
    plot = new(2,graphic)
    plot(0) = gsn_csm_contour_map(wks,w_ERA5,sdres)
    contour_ERA5 = gsn_csm_contour(wks,height_ERA5({minlat:maxlat},{minlon:maxlon}),shres)
    vector_ERA5  = gsn_csm_vector(wks,qu_ERA5({minlat+0.25:maxlat-0.25},{minlon+0.25:maxlon-0.25}),qv_ERA5({minlat+0.25:maxlat-0.25},{minlon+0.25:maxlon-0.25}),vcres)
    overlay(plot(0),vector_ERA5)
    overlay(plot(0),contour_ERA5)

    sdres@gsnLeftString = "b CTL"
    sdres@sfXArray = lonCell
    sdres@sfYArray = latCell
    sdres@trGridType = "TriangularMesh"
    plot(1) = gsn_csm_contour_map(wks,w_ctl,sdres)
    shres@gsnLeftString = ""
    contour_ctl = gsn_csm_contour(wks,height_ctl({minlat:maxlat},{minlon:maxlon}),shres)
    vector_ctl  = gsn_csm_vector(wks,qu_ctl({minlat+0.25:maxlat-0.25},{minlon+0.25:maxlon-0.25}),qv_ctl({minlat+0.25:maxlat-0.25},{minlon+0.25:maxlon-0.25}),vcres)
    overlay(plot(1),vector_ctl)
    overlay(plot(1),contour_ctl)

    lat_spacing  = 5
    lon_spacing  = 5
    add_lc_labels(wks,plot(0),minlat,maxlat,minlon,maxlon,lat_spacing,lon_spacing)
    add_lc_labels(wks,plot(1),minlat,maxlat,minlon,maxlon,lat_spacing,lon_spacing)

;Create individual label for (a)
    lbresa = True
    lbresa@vpXF = 0.23
    lbresa@vpYF = 0.24
    lbresa@vpWidthF = 0.54
    lbresa@vpHeightF= 0.06

    lbresa@lbPerimOn = False
    lbresa@lbBoxLinesOn = False
    lbresa@lbBoxSeparatorLinesOn = False
    lbresa@lbBoxLineThicknessF = 1.2*N_res
    lbresa@lbFillColors  = sd_colors
    lbresa@lbMonoFillPattern = True
    lbresa@lbLabelFontHeightF = 0.013
    lbresa@lbLabelAlignment   = "InteriorEdges"
    ;lbresa@lbLabelPosition = "Left"
    lbresa@lbOrientation = "Horizontal"
    lbresa@lbTitlePosition = "Bottom"
    ;lbresa@lbTitleDirection = "Across"
    ;lbresa@lbTitleAngleF = 270.
    ;lbres@lbTitleJust = "TopCenter"
    lbresa@lbTitleFontHeightF = 0.017
    lbresa@lbTitleOffsetF = 0.2
    lbresa@lbTitleExtentF = 0.25
    lbresa@lbTitleString = "~F25~Vertical speed at 500 hPa (m/s)";optional
    lbresa@lbLabelStride = 5
    nboxes = dimsizes(sd_colors)
    labels = "~F25~"+sd_cnlevels
    lbid_wspd = gsn_create_labelbar(wks,nboxes,labels,lbresa)
    draw(lbid_wspd)

    ;drawNDCGrid(wks)
    ;draw(plot)
    ;frame(wks)

    resP = True
    resP@gsnPanelLabelBar = False
    resP@gsnMaximize = True
    resP@gsnPanelRowSpec = True
    resP@gsnPanelCenter = True
    ;resP@gsnPanelBottom = 0.12
    gsn_panel(wks,plot,(/2/),resP)
    print_clock("End")
end
