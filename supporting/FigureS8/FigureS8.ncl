;load "/work/home/jungu/my_NCL/WCHAR.ncl"
begin
    CMA                = "./2305Doksuri_JMA"
    CMA_id = asciiread(CMA,(/9,6/),"integer")
    CMA_time = CMA_id(:,0)
    CMA_yyyy = CMA_time/1000000
    CMA_mmddhh = CMA_time - CMA_yyyy * 1000000

    CMA_mm = CMA_mmddhh/10000
    CMA_ddhh = CMA_mmddhh - CMA_mm * 10000

    CMA_dd = CMA_ddhh / 100
    CMA_hh  = CMA_ddhh - CMA_dd*100

    CMA_lon = tofloat(CMA_id(:,3))
    CMA_lat = tofloat(CMA_id(:,2))
    CMA_lon := CMA_lon/10
    CMA_lat := CMA_lat/10

    res_list = (/"CTL","RM_T_MP"/)
    finame = "./2305Doksuri_JMA_" + res_list + ".txt"

    ctl_id = asciiread(finame(0),(/12,4/),"integer")
    ctl_time = toint(ctl_id(:,0))
    ctl_yyyy = ctl_time/1000000
    ctl_mmddhh = ctl_time - ctl_yyyy * 1000000
    ctl_mm = ctl_mmddhh/10000
    ctl_ddhh = ctl_mmddhh - ctl_mm * 10000
    ctl_dd = ctl_ddhh / 100
    ctl_hh  = ctl_ddhh - ctl_dd*100

    ctl_id := asciiread(finame(0),(/12,4/),"float")
    ctl_lon = ctl_id(:,2)
    ctl_lat = ctl_id(:,1)

    rm_t_mp_id = asciiread(finame(1),(/16,4/),"integer")
    rm_t_mp_time = toint(rm_t_mp_id(:,0))
    rm_t_mp_yyyy = rm_t_mp_time/1000000
    rm_t_mp_mmddhh = rm_t_mp_time - rm_t_mp_yyyy * 1000000
    rm_t_mp_mm = rm_t_mp_mmddhh/10000
    rm_t_mp_ddhh = rm_t_mp_mmddhh - rm_t_mp_mm * 10000
    rm_t_mp_dd = rm_t_mp_ddhh / 100
    rm_t_mp_hh  = rm_t_mp_ddhh - rm_t_mp_dd*100

    rm_t_mp_id := asciiread(finame(1),(/16,4/),"float")
    rm_t_mp_lon = rm_t_mp_id(:,2)
    rm_t_mp_lat = rm_t_mp_id(:,1)

    static_fi = addfile("/home/export/online1/mdt00/shisuan/swustc/jungu/MPAS/meshes/rotated_4-60km_28N117E_785410/init_static.nc","r")
    R2D = get_r2d("double")
    latCell = static_fi->latCell*R2D
    lonCell = static_fi->lonCell*R2D
    ter = static_fi->ter

    N_res = 4
    wks_type = "png"
    wks_type@wkWidth  = 1024*N_res;
    wks_type@wkHeight = 1024*N_res
    wks  = gsn_open_wks(wks_type,"FigureS8")   ; send graphics to PNG file

    res                = True              ; plot mods desired
    res@gsnDraw        = False             ; don't draw the plots
    res@gsnFrame       = False             ; don't advance the frame
    res@gsnLeftString = ""
    res@gsnLeftStringFontHeightF = 0.023
    res@gsnStringFont = 25
    res@gsnLeftStringOrthogonalPosF = 0.02
    res@vpHeightF = 0.7
    res@vpWidthF = 0.7
    res@vpYF = 0.9
    ;res@gsnCenterStringFontHeightF = 0.03  ; set the center string font height

    ;-------------------------------------------------------------------------------
    ;----------The following two resources, mpGridAndLimbOn and mpPerimOn, will be turned on
    ;----------and off depending on the map projections used below.
    ;-------------------------------------------------------------------------------  
    ;res@mpGridAndLimbOn   = True           ; turn on lat/lon lines
    ;res@mpPerimOn         = True               ; turn off perimeter

    ;res@mpGridLatSpacingF =  90            ; change latitude  line spacing
    ;res@mpGridLonSpacingF = 180.           ; change longitude line spacing
    ;res@mpGridLineColor   = "transparent"  ; trick ncl into drawing perimeter

    ;res@mpCenterRotF = 0.
    ;res@mpLeftAngleF = 10
    ;mas tickmark

    ;res@mpProjection = "Satellite"
    res@mpProjection = "CylindricalEquidistant"
    ;res@mpProjection = "CylindricalEquidistant"
    res@mpLimitMode = "LatLon"
    ;res@mpCenterLonF = 130
    res@mpMaxLatF = 40
    res@mpMinLatF = 25
    res@mpMaxLonF = 125
    res@mpMinLonF = 110
    ;res@pmTickMarkDisplayMode = "Always"

    res@mpDataSetName            = "$HOME/jungu/data/database/Earth..4"
    res@mpDataBaseVersion        = "MediumRes"
    res@mpOutlineOn              =  True
    res@mpOutlineSpecifiers        = (/"China","China:Provinces"/)
    res@mpGeophysicalLineColor      = "black"
    ;res@mpGeophysicalLineColor      = "green"
    res@mpGeophysicalLineThicknessF = 4.0*N_res
    res@mpProvincialLineColor = "black"
    res@mpProvincialLineThicknessF =  2.0*N_res

    res@mpFillOn                 = True
    ;res@mpMonoFillColor          = True
    ;res@mpFillColor = "lightblue"
    res@mpFillDrawOrder  = "PostDraw"
    res@mpOceanFillColor         = "lightblue"
    ;res@mpInlandWaterFillColor = "lightblue"
    res@mpLandFillColor = "transparent"
    ;res@gsnCenterString = res@mpProjection+" Projection"
    res@tmXTOn = False
    res@tmYROn = False
    res@tmBorderThicknessF = 4*N_res
    res@tmYLMajorThicknessF = 2.5*N_res
    res@tmYLMajorLengthF    = 0.006
    res@tmYLMinorThicknessF = 2.5*N_res
    res@tmYLMinorLengthF    = 0.004
    res@tmXBMajorThicknessF = 2.5*N_res
    res@tmXBMajorLengthF    = 0.006
    res@tmXBMinorThicknessF = 2.5*N_res
    res@tmXBMinorLengthF    = 0.004
    res@tmXBLabelFont = 25
    res@tmYLLabelFont = 25

    res@tmXBMinorOn = True
    res@tmYLMinorOn = True
    res@tmXBMode = "Explicit"
    res@tmXBValues = ispan(105,155,5)
    res@tmXBMinorValues = ispan(104,156,1)
    res@tmXBLabels = "~F25~" + abs(res@tmXBValues) + "~S~o~N~E"
    res@tmYLMode = "Explicit"
    res@tmYLValues = ispan(5, 45,5)
    res@tmYLMinorValues = ispan(4, 46,1)
    res@tmYLLabels = "~F25~" + abs(res@tmYLValues) + "~S~o~N~N"

    res@tmXBLabelDeltaF = -0.5
    res@tmYLLabelDeltaF = -0.5
    res@tmXBLabelFontHeightF = 0.016
    res@tmYLLabelFontHeightF = 0.016

    res@cnFillDrawOrder = "Draw"
    res@cnFillOn = True
    res@cnLinesOn = False
    res@cnInfoLabelOn   = False
    res@cnLineLabelsOn  = False

    res@cnFillMode = "RasterFill"
    res@cnRasterSmoothingOn = True

    res@cnLevelSelectionMode = "ExplicitLevels"
    sd_cnlevels = fspan(0,2000,51)
    sd_cmap =  read_colormap_file("MPL_terrain")
    sd_colors = new((/52,4/),"float")
    sd_colors = sd_cmap(12:114:2,:)
    res@cnLevels        = sd_cnlevels
    res@cnFillColors    = sd_colors
    res@lbLabelBarOn    = False
    res@sfXArray = lonCell
    res@sfYArray = latCell
    res@gsnRightString = ""



    ;-------Plot---------
    map = gsn_csm_contour_map(wks,ter,res)

    print("draw map")
    ;colors = (/"Brown","cadetblue","cornflowerblue"/)
    colors = (/"Violetred","yellow"/)
    ;draw box lines
    mkres  = True
    mkres@gsMarkerIndex  = 16
    mkres@gsMarkerSizeF  = 0.01
    mkres@gsMarkerThicknessF  = 1.*N_res

    pres                  = True               ; polyline resources
    pres@gsLineThicknessF = 5*N_res                ; line thickness
    pres@gsLineColor      = "black"

    best_track = gsn_add_polyline(wks,map,CMA_lon,CMA_lat,pres); draw the traj
    best_track_mk = gsn_add_polymarker(wks,map,CMA_lon,CMA_lat,mkres); draw the traj

    pres@gsLineColor      = colors(0)
    mkres@gsMarkerColor  = colors(0)
    ctl_track = gsn_add_polyline(wks,map,ctl_lon,ctl_lat,pres); draw the traj
    ctl_track_mk = gsn_add_polymarker(wks,map,ctl_lon,ctl_lat,mkres); draw the traj

    pres@gsLineColor      = colors(1)
    mkres@gsMarkerColor  = colors(1)
    rm_t_mp_track = gsn_add_polyline(wks,map,rm_t_mp_lon,rm_t_mp_lat,pres); draw the traj
    rm_t_mp_track_mk = gsn_add_polymarker(wks,map,rm_t_mp_lon,rm_t_mp_lat,mkres); draw the traj


    ;draw larger marker for 00h of that day
    mkres@gsMarkerIndex  = 16
    mkres@gsMarkerSizeF  = 0.012
    mkres@gsMarkerThicknessF  = 1.5*N_res

    txres = True
    txres@txFont = 25
    txres@txFontHeightF = 0.015

    ;for all plots add CMA track and time labels

    dum = 0
    dum8 = -1
    dum1 = 1
    do iCMA =0, 8
        if(CMA_hh(iCMA).eq.0)then
            txres@txFontColor = "Black"
            mkres@gsMarkerColor  = "Black"
            ;dum@$unique_string("")$ = gsn_add_text(wks,map,tostring(sprinti("%02i",CMA_dd(iCMA))),CMA_lon(iCMA) + .5,CMA_lat(iCMA) + 1.,txres)
            dum1@$unique_string("")$ = gsn_add_polymarker(wks,map,CMA_lon(iCMA),CMA_lat(iCMA),mkres)
            ;if(CMA_dd(iCMA).eq.25 .or. CMA_dd(iCMA).eq.26 .or. CMA_dd(iCMA).eq.24) then
            if(CMA_hh(iCMA).eq.0) then
                dum8@$unique_string("")$ = gsn_add_text(wks,map,tostring(sprinti("%02i",CMA_dd(iCMA))),CMA_lon(iCMA) + .3,CMA_lat(iCMA) + .1,txres)
            end if
        end if
    end do

    dum = 2
    dum1 = 3
    dum4 = 9
    do iMPAS =0, 11
        if(ctl_hh(iMPAS).eq.0)then
            txres@txFontColor = colors(0)
            mkres@gsMarkerColor  = colors(0)
            dum1@$unique_string("ctl")$ = gsn_add_polymarker(wks,map,ctl_lon(iMPAS),ctl_lat(iMPAS),mkres)
            if(ctl_dd(iMPAS).eq.29 .or. ctl_dd(iMPAS).eq.30 .or. ctl_dd(iMPAS).eq.31) then
            ;if(ctl_hh(iMPAS).eq.0) then
                dum@$unique_string("ctl")$ = gsn_add_text(wks,map,tostring(ctl_dd(iMPAS)),ctl_lon(iMPAS)-0.3,ctl_lat(iMPAS),txres)
            end if
        end if
    end do
    do iMPAS =0, 15
        if(rm_t_mp_hh(iMPAS).eq.0)then
            txres@txFontColor = colors(1)
            mkres@gsMarkerColor  = colors(1)
            dum1@$unique_string("rm_t_mp")$ = gsn_add_polymarker(wks,map,rm_t_mp_lon(iMPAS),rm_t_mp_lat(iMPAS),mkres)
            if(ctl_dd(iMPAS).eq.29 .or. ctl_dd(iMPAS).eq.30 .or. ctl_dd(iMPAS).eq.31) then
            ;if(rm_t_mp_hh(iMPAS).eq.0) then
                dum@$unique_string("rm_t_mp")$ = gsn_add_text(wks,map,tostring(rm_t_mp_dd(iMPAS)),rm_t_mp_lon(iMPAS)+0.3 ,rm_t_mp_lat(iMPAS),txres)
            end if

        end if
    end do
    lbres = True
    lbres@vpXF = 0.23
    lbres@vpYF = 0.15
    lbres@vpWidthF = 0.54
    lbres@vpHeightF= 0.06

    lbres@lbPerimOn = False
    lbres@lbBoxLinesOn = False
    lbres@lbBoxSeparatorLinesOn = False
    lbres@lbBoxLineThicknessF = 4.0*N_res
    lbres@lbFillColors  := sd_colors
    lbres@lbMonoFillPattern = True
    lbres@lbLabelFontHeightF = 0.010
    lbres@lbLabelAlignment   = "InteriorEdges"
    lbres@lbOrientation = "Horizontal"
    lbres@lbTitlePosition = "Bottom"
    ;lbres@lbTitleJust = "TopCenter"
    lbres@lbTitleFontHeightF = 0.014
    lbres@lbTitleOffsetF = 0.2
    lbres@lbTitleExtentF = 0.25
    lbres@lbTitleString = "~F25~Terrain height (m)";optional
    lbres@lbLabelStride = 1
    nboxes := dimsizes(sd_colors)
    labels := "~F25~"+sd_cnlevels
    lbid_rain = gsn_create_labelbar(wks,nboxes,labels,lbres)
    draw(lbid_rain)

    lgcolors =  new(3,string)
    lgcolors(0) = "black"
    lgcolors(1:2) = colors
    lgLabels = "~F25~" + (/"   Best Track ","   CTL ","   RM_T_MP "/)
    lgres = True
    ;lgres@tfPolyDrawOrder = "Draw"

    lgres@vpWidthF = 0.2
    lgres@vpHeightF = 0.14
    lgres@lgAutoManage = False
    
    lgres@lgMonoDashIndex = True
    lgres@lgDashIndex = 0

    lgres@lgMonoItemType = True
    lgres@lgItemType = "MarkLines"

    lgres@lgMonoMarkerIndex = True
    lgres@lgMarkerIndex = 16
    lgres@lgMonoMarkerThickness = True
    lgres@lgMarkerThicknessF = 2
    lgres@lgMarkerSizeF = 0.01
    lgres@lgMarkerColors  = lgcolors

    lgres@lgMonoLineColor = False
    lgres@lgLineColors    = lgcolors
    lgres@lgMonoLineThickness = True
    lgres@lgLineThicknessF = 20

    lgres@lgBoxBackground = "Transparent"
    lgres@lgPerimFill           = "SolidFill"
    lgres@lgLabelStrings = lgLabels
    lgres@lgLabelFontHeightF = 0.07
    lgres@lgPerimOn = False
    lgres@lgItemCount =3
    lgres@lgItemOrder = (/2,1,0/)
    lgres@lgBoxMinorExtentF = 0.4
    draw(map)
    gsn_legend_ndc(wks,3,lgLabels,0.6,0.7,lgres)
    print("draw legend")

    ;fontres = True
    ;fontres@fontNDC = True
    ;;fontres@fontName = "S"
    ;fontres@fontEncoding = "utf8"
    ;cn_string = "GS（2024）0650号"
    ;fontX(wks,map,cn_string,0.8,0.1,fontres)

    ;drawNDCGrid(wks)

    frame(wks)
end
