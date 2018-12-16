// Please see documentation at https://docs.microsoft.com/aspnet/core/client-side/bundling-and-minification
// for details on configuring this project to bundle and minify static web assets.

// Write your Javascript code.
$.extend(window, {
    apiUrl: function (url) {
        return "/api" + url;
    }
    , cFloat: function (value) {
        //return SH(v).toFloat();
        if (typeof value === "number") return value;
        var decimal = ".";
        var regex = new RegExp("[^0-9-" + decimal + "]", ["g"]),
            unformatted = parseFloat(
                ("" + value)
                    .replace(/\((.*)\)/, "-$1")
                    .replace(regex, '')
                    .replace(decimal, '.')
            );
        return !isNaN(unformatted) ? unformatted : 0;
    }
    , cInt: function (value) {
        //return SH(v).toInt();
        if (typeof value === "number") return parseInt(value);
        var decimal = ".";
        var regex = new RegExp("[^0-9-" + decimal + "]", ["g"]),
            unformatted = parseInt(
                ("" + value)
                    .replace(/\((.*)\)/, "-$1")
                    .replace(regex, '')
                    .replace(decimal, '.')
            );
        return !isNaN(unformatted) ? unformatted : 0;
    }
    , cString: function (v) {
        var result = SH(v).s;
        return (result == "null" ? "" : result);
    }
    , cDateParse: function (v) {
        var oval = v;
        var isMonthExist = false;
        v = SH(v).replaceAll("-", "/").s;
        var spaceArr = v.split(" ");
        var splitValue = $.trim(spaceArr[0]);
        var timeValue = "";
        if (spaceArr.length > 1) {
            timeValue = $.trim(spaceArr[1]);
        }
        var arr = splitValue.toString().split("/");
        //console.log('cDateParse arr=',arr);
        if (arr.length >= 3) {
            var months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
            if (SH(arr[1]).isNumeric() == false) {
                var i;
                var d = arr[0];
                var m = '';
                var y = arr[2];
                for (i = 1; i <= months.length; i++) {
                    if (months[i - 1].toLowerCase() == arr[1].toLowerCase()) {
                        isMonthExist = true;
                        m = ((i < 10) ? "0" + i : i);
                    }
                }
                //console.log('d=',d,'m=',m,'y=',y);
                v = y + "/" + m + "/" + d;
                if (timeValue != '') {
                    v += " " + timeValue;
                }
            }
        }
        if (isMonthExist == false)
            v = oval;
        return v;
    }
    , cDateObj: function (v) {
        //console.log('cDateObj v=',v);
        var result = new Date(cDateParse(v));
        //console.log('cDateObj result=',result);
        return result;
    }
    , cDateString: function (v) {
        if (v.toString().indexOf('GMT+') > 0) {
            return v;
        } else {
            //console.log('cDateString Start v=',v);
            v = cDateParse(v);
            v = cString(moment(v).format("YYYY-MM-DD"));
            if ($.trim(v).toString().toLowerCase() == 'invalid date') { v = ''; }
            //console.log('cDateString v=',v);
            return v;
        }
    }
    , cBool: function (v) {
        return SH(v).toBoolean();
    }
    , formatDate: function (d, f) {
        if (cString(d) == "") {
            return "";
        }
        if (cString(f) == "") {
            f = "DD/MMM/YYYY";
        }
        var ty = $.type(d);
        if (ty == "object")
            return "";

        console.log('f=',f);
        d = cDateString(d.toString());
        var m = moment(d);
        if (m.get('year') <= 1901)
            return "";
        else
            return m.format(f);
    }
    , getMonthFirstDate: function (value) {
        var dt = value;
        if (typeof value == "string") {
            dt = new Date(value);
        }
        return (dt.getMonth() + 1) + '/01/' + dt.getFullYear();
    }
    , formatNumber: function (d, decimalPlace) {
        var precision = cFloat(decimalPlace);
        if (precision <= 0) {
            precision = 2;
        }
        d = cFloat(d);
        if (d == 0) {
            return "";
        } else {
            return accounting.formatNumber(d, { precision: precision, checkNegative: false });
        }
    }

    , formatPercentage: function (d, decimalPlace) {
        var precision = cFloat(decimalPlace);
        if (precision <= 0) {
            precision = 2;
        }
        d = cFloat(d);
        if (d == 0) {
            return "";
        } else {
            return accounting.formatNumber(d, { precision: precision, checkNegative: false }) + '%';
        }
    }
});