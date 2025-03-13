load "./boxplot_func.ncl"
;*********************************************
begin
    CTL_array = asciiread("./CTL_member.txt",-1,"double")
    RM_THQ_array = asciiread("./RM_THQ_member.txt",-1,"double")
    RM_TH_array = asciiread("./RM_TH_member.txt",-1,"double")
    RM_Q_array = asciiread("./RM_Q_member.txt",-1,"double")

    dims = dimsizes(CTL_array)
    x25  = round(.25*dims,3)-1     ; -1 to account for NCL indexing starting
    x75  = round(.75*dims,3)-1     ; at 0

    qsort(CTL_array)         ; sort the data
    qsort(RM_THQ_array)         ; sort the data
    qsort(RM_TH_array)         ; sort the data
    qsort(RM_Q_array)         ; sort the data

    iarr=new((/4,5/),double) ; fill with minimum, 25th percentile, median, 
                          ; 75th percentile, maximum of each time series
  iarr(0,:) = (/min(CTL_array),CTL_array(x25),dim_median(CTL_array),CTL_array(x75),max(CTL_array)/)  
  iarr(1,:) = (/min(RM_THQ_array),RM_THQ_array(x25),dim_median(RM_THQ_array),RM_THQ_array(x75),max(RM_THQ_array)/)  
  iarr(2,:) = (/min(RM_TH_array),RM_TH_array(x25),dim_median(RM_TH_array),RM_TH_array(x75),max(RM_TH_array)/)  
  iarr(3,:) = (/min(RM_Q_array),RM_Q_array(x25),dim_median(RM_Q_array),RM_Q_array(x75),max(RM_Q_array)/)  

 N_res = 2
 wks_type = "png"
 wks_type@wkWidth  = 1024*N_res;
 wks_type@wkHeight = 1024*N_res
 ;wks_type@wkPDFResolution = 6000
 wks = gsn_open_wks(wks_type, "./Box_test")

  res            = True                         ; plot mods desired
  res@vpWidthF   = 0.7
  res@vpHeightF  = 0.64
  res@vpXF = 0.15
  res@vpYF = 0.9
  ;res@gsnDraw = False
  ;res@gsnFrame= False

  res@tmXBLabelFont = 25
  res@tmXBLabels = (/"CTL","RM_THQ","RM_TH","RM_Q"/) ; labels for each box
  res@tmXBLabelAngleF = 30.
  ;res@gsnLeftString = "~F25~Rainfall in 29-31 July" not useful
  res@trYMinF = 80
  res@trYMaxF = 160
  res@tmYLLabelFont = 25
  ;res@tmYLLabel
  ;set tickmark and border
  res@tmXTBorderOn = True
  res@tmYRBorderOn = True
  res@tmBorderThicknessF = 4.5*N_res
  res@tmYLMajorThicknessF = 3.5*N_res
  res@tmYLMinorThicknessF = 3.5*N_res
  res@tmYLMajorLengthF    = 0.011
  res@tmYLMajorOutwardLengthF = 0.011
  res@tmYLMinorLengthF    = 0.005
  res@tmYLMinorOutwardLengthF = 0.005
  res@tmXBMajorThicknessF = 3.5*N_res
  res@tmXBMinorThicknessF = 3.5*N_res
  res@tmXBMajorLengthF    = 0.011
  res@tmXBMajorOutwardLengthF = 0.011
  res@tmXBMinorLengthF    = 0.006
  res@tmXBMinorOutwardLengthF = 0.006

  boxopt = True
  boxopt@boxWidth = 0.15

  lineres = True
  lineres@gsLineThicknessF = 4.5*N_res

  plot = boxplot(wks,(/0,1,2,3/),iarr,boxopt,res,lineres)	
  refline = True
  refline@gsLineThicknessF = 4*N_res
  refline@gsLineDashPattern = 1
  ref = new(2,double)
  ref = dim_median(CTL_array)
  ;refline_plot = gsn_csm_xy(wks, (/0,1,2,3/),ref , refline)
  anno_id = gsn_add_polyline(wks,plot, (/-10,10/),ref, refline)
  txres = True
  txres@txFont = 25
  txres@txFontHeightF = 0.022
  gsn_text_ndc(wks,"(b) Rainfall in 29-31 July", 0.31, 0.915, txres)


;  drawNDCGrid(wks)
  draw(wks)                                    ; boxplot does not call these
  frame(wks)                                   ; for you
end
