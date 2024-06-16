begin
    print_clock("start")
;---Processing----------------
    box_minlat  = 35
    box_maxlat  = 41
    box_minlon  = 112
    box_maxlon  = 117


    data_path = "../data/Figure1/"
    CHM_fi = addfile(data_path + "CHM_PRE_0.1dg_19612022.nc", "r")
    years = CHM_fi->years
    hours = CHM_fi->time
    lat = CHM_fi->latitude
    lon = CHM_fi->longitude
    pre = CHM_fi->pre
    delete(pre@missing_value)
    pre@_FillValue = -99.9

    re   = 6.37122e06
    rad  = 4.0 * atan(1.0) / 180.0
    con  = re * rad
    clat = cos(lat * rad)           ; cosine of latitude

    dlon = (lon(2) - lon(1))        ; assume dlon is constant
    dlat = (lat(2) - lat(1))        ; assume dlat is constant

    dx   = con * dlon * clat        ; dx at each latitude
    dy   = con * dlat               ; dy is constant
    dydx = tofloat(dy * dx)                  ; dydx(nlat)

    wgt  = new((/dimsizes(lat), dimsizes(lon)/), typeof(pre))
    wgt  = conform(wgt, dydx, 0)
    wgt!0 = "lat"
    wgt!1 = "lon"
    wgt&lat = lat
    wgt&lon = lon

    time_days = cd_convert(hours,"days since 1961-01-01 00:00:00")
    utc_date = cd_calendar(time_days, 0)
    yyyymmdd = cd_calendar(time_days, -2)
    ind_avg = ind(utc_date(:,1) .eq. "6".or. utc_date(:,1).eq."7" .or. utc_date(:,1).eq."8");June July August
    ;print("start: " + ind_start + " end: " + ind_end)
    yyyymmdd_select = yyyymmdd(ind_avg)
    utc_date_select = utc_date(ind_avg,:)
    num_ind = dimsizes(ind_avg)
    print("num_ind: " + num_ind + " num_ind/62 :"  + num_ind/62)
    pre_select = pre(ind_avg,{box_minlat:box_maxlat},{box_minlon:box_maxlon})
    pre_select_box = wgt_areaave2(pre_select,wgt({box_minlat:box_maxlat},{box_minlon:box_maxlon}),0)

    rx3day_year = new((/62,90/),"float")
    rx1day_year = new((/62,92/),"float")
    year_list = ispan(1961,2022,1)
    do iyear = 0, 61
        year_ind = ind(utc_date_select(:,0) .eq. ""+year_list(iyear))
        pre_select_box_year := pre_select_box(year_ind)
        do i=0, 89
            rx3day_year(iyear,i) = sum(pre_select_box_year(i:i+2))
        end do
        rx1day_year(iyear,:) = pre_select_box_year(:)
        ;nyear_pre(iyear) = avg(pre_select_box(iyear*3:iyear*3+2))*3
    end do
    rx3day = dim_max_n(rx3day_year, 1)
    rx1day = dim_max_n(rx1day_year, 1)
    print(year_list(20))
    print(year_list(59))

    rx3day_1981_2020_avg = avg(rx3day(20:59))
    print("avg rx3day " + rx3day_1981_2020_avg)
    rx1day_1981_2020_avg = avg(rx1day(20:59))
    print("avg rx1day " + rx1day_1981_2020_avg)

    ;pre_box = pre(0,{box_minlat:box_maxlat},{box_minlon:box_maxlon})
    ;do iyear = 0, nyear-2
    ;    print("Processing " + year_list(iyear))
    ;    year_start := sprinti("%04i",year_list(iyear)) + "0729"
    ;    year_end := sprinti("%04i",year_list(iyear)) + "0731"
    ;    ind_start := ind(yyyymmdd .eq. year_start)
    ;    ind_end   := ind(yyyymmdd .eq. year_end)
    ;    pre_select:= pre(ind_start:ind_end,{box_minlat:box_maxlat},{box_minlon:box_maxlon})
    ;    pre_select_avg := dim_avg_n(pre_select,0)
    ;    pre_select_avg_3day = pre_select_avg * 3
    ;    copy_VarCoords(pre_box,pre_select_avg_3day)
    ;    nyear_pre(iyear) = wgt_areaave2(pre_select_avg_3day,wgt({box_minlat:box_maxlat},{box_minlon:box_maxlon}),0)
    ;end do

    CLDAS_fi = addfile(data_path + "/regrid/CLDAS_Doksuri_stod_CHM.nc","r")
    rain_3day = CLDAS_fi->rain_3day
    rain = CLDAS_fi->rain
    rain_3day = where(ismissing(rain_3day),-99.9,rain_3day)
    rain_3day@missing_value = -99.9
    rain_3day@_FillValue = -99.9
    rx3day_2023 = wgt_areaave2(rain_3day({box_minlat:box_maxlat},{box_minlon:box_maxlon}),wgt({box_minlat:box_maxlat},{box_minlon:box_maxlon}),0)

    rain = where(ismissing(rain),-99.9,rain)
    rain@missing_value = -99.9
    rain@_FillValue = -99.9
    rain_box_avg = wgt_areaave2(rain(:,{box_minlat:box_maxlat},{box_minlon:box_maxlon}),wgt({box_minlat:box_maxlat},{box_minlon:box_maxlon}),0)
    rain_day = new((/3/),"float")
    do iday = 0, 2
        rain_day(iday) = avg(rain_box_avg(24*iday:24*iday+23))*24
    end do
    rx1day_2023 = max(rain_day)

    rx3day := array_append_record(rx3day, rx3day_2023, 0)
    asciiwrite("./rx3day.txt", rx3day)
    rx3day_anomaly = rx3day - rx3day_1981_2020_avg
    asciiwrite("./rx3day_anomaly.txt", rx3day_anomaly)
    rx1day := array_append_record(rx1day, rx1day_2023, 0)
    asciiwrite("./rx1day.txt", rx1day)
    rx1day_anomaly = rx1day - rx1day_1981_2020_avg
    asciiwrite("./rx1day_anomaly.txt", rx1day_anomaly)

    ;test area-weight average and simple average
    ;pre_avg_3day_box = pre_avg_3day({box_minlat:box_maxlat},{box_minlon:box_maxlon})
    ;pre_avg_3day_box_avg2 = wgt_areaave2(pre_avg_3day_box, wgt({box_minlat:box_maxlat},{box_minlon:box_maxlon}),0)
    ;print("" + pre_avg_3day_box_avg2)
    ;;pre_avg_3day_box_avg = dim_avg_n(pre_avg_3day_box, (/0,1/))
    ;pre_avg_3day_box_avg = avg(pre_avg_3day_box)
    ;print("" + pre_avg_3day_box_avg)
    print_clock("End")
end
