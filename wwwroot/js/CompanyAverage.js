
function Company() {
    var self = this;

    this.index = -1;
    this.company_json = null;
 
    this.startTechnical = function () {
        console.log('self.index=', self.index);
        var symbols = '';
        for (var i = 0; i < self.company_json.length; i++) {
            var c = self.company_json[i];
            if (cString(c.LastTradingDate) == '') {
                c.LastTradingDate = '01/01/2017';
            }
            if (cString(c.InvestingUrl) != '') {
                if (c.InvestingUrl.indexOf('?cid=') > -1) {
                    var arr = c.InvestingUrl.split('?cid=');
                    //console.log(arr);
                    c.InvestingUrl = arr[0] + '-technical' + '?cid=' + arr[1];
                } else {
                    c.InvestingUrl = c.InvestingUrl + '-technical';
                }
                symbols += c.CompanyID + '|' + c.InvestingUrl + '|' + formatDate(c.LastTradingDate, 'DD/MM/YYYY') + '|' + formatDate(new Date(), 'DD/MM/YYYY') + ',';
            }
        }
        if (symbols != '') {
            symbols = symbols.substring(0, symbols.length - 1);
        }
        console.log(symbols);
        if (symbols != '') {
            console.log('call gccmd', symbols);
            var $gcb_cmd = $("#gcb_cmd");
            $gcb_cmd.attr("cmd", "technical-history");
            $gcb_cmd.attr("symbol", symbols);
            $gcb_cmd.click();
        }
    }
}

var _COMPANY = new Company();

$(function () {
    var $tbl = $("#tblCompany");

    var $LastTradingDate = $("#LastTradingDate");

    $LastTradingDate.datepicker({
        autoclose: true
    }).on('changeDate', function (selected) {
        console.log('monthpicker=', selected.date);
        $LastTradingDate.val(formatDate(selected.date));
        $tbl.flexReload2();
    });
 
    $tbl.flexigrid2({
        usepager: true,
        useBoxStyle: false,
        url: apiUrl("/Company/AverageList"),
        rpOptions: [10, 20, 30, 40, 50, 100, 200, 500, 1000],
        rp: 1000,
        onSubmit: function (p) {
            p.params = [];
            p.params.push({ "name": "CompanyIDs", "value": $("#CompanyIDs").val() });
            p.params.push({ "name": "CategoryIDs", "value": $("#CategoryIDs").val() });
            p.params.push({ "name": "LastTradingDate", "value": $("#LastTradingDate").val() });
            var chk = $("#chkIsBookMarkCategory")[0];
            if (chk.checked) {
                p.params.push({ "name": "IsBookMarkCategory", "value": true })
            }
        },
        onSuccess: function (t, g) { },
        onTemplate: function (data) {
            _COMPANY.company_json = data.rows;
            var tbody = $("tbody", $tbl);
            tbody.empty();
            $("#grid-template").tmpl(data).appendTo(tbody);
        },
        onPaginationElement: function () {
            return $(".manual-pagination");
        },
        onPaginationStatusElement: function () {
            return $("#paging_status");
        },
        onRPSelectElement: function () {
            return $("#rows2");
        },
        resizeWidth: true,
        method: "GET",
        sortname: "CompanyName",
        sortorder: "asc",
        autoload: true,
        height: 0,
        applyFixedHeader: true
    });

    $("#CompanyIDs").val("").select2({
        placeholder: "Select Company",
        minimumInputLength: 0,
        maximumSelectionSize: 1000,
        minimumResultsForSearch: 0,
        multiple: true,
        allowClear: false,
        delay: 300,
        width: "300px",
        query: function (query) {
            $.getJSON(apiUrl("/Company/FindCompanies?term=" + query.term), function (data) {
                //var data = [];
                //for(var i = 0;i<100;i++){
                //    data.push({"id":"Contact_"+i,"label":"Contact_"+i});
                //}
                var callback = function (data, page) {
                    var s2data = [];
                    $.each(data, function (i, d) {
                        s2data.push({ "id": d.id, "text": d.label, "source": d });
                    });
                    return { results: s2data };
                }
                query.callback(callback(data, query.page));
            });
        }
    }).on("change", function (e) {
        $tbl.flexReload2();
    });


    $("#CategoryIDs").val("").select2({
        placeholder: "Select Category",
        minimumInputLength: 0,
        maximumSelectionSize: 1000,
        minimumResultsForSearch: 0,
        multiple: true,
        allowClear: false,
        delay: 300,
        width: "300px",
        query: function (query) {
            $.getJSON(apiUrl("/Category/FindCategories?term=" + query.term), function (data) {
                //var data = [];
                //for(var i = 0;i<100;i++){
                //    data.push({"id":"Contact_"+i,"label":"Contact_"+i});
                //}
                var callback = function (data, page) {
                    var s2data = [];
                    $.each(data, function (i, d) {
                        s2data.push({ "id": d.id, "text": d.label, "source": d });
                    });
                    return { results: s2data };
                }
                query.callback(callback(data, query.page));
            });
        }
    }).on("change", function (e) {
        $tbl.flexReload2();
    });
   
    var $lnkTechnicalDownload = $("#lnkTechnicalDownload");

    $lnkTechnicalDownload.click(function () {
        _COMPANY.startTechnical();
    });

    var $btnTechnicalUpdateCSV = $("#btnTechnicalUpdateCSV");
    $btnTechnicalUpdateCSV.click(function () {
        var $technical_csv = $("#technical_csv");
        console.log('technical_csv=', $technical_csv.val());
        var url = apiUrl("/Company/UpdateTechnical");
        var d = { "csv": $technical_csv.val() };
        $.ajax({
            "url": url,
            "cache": false,
            "type": "POST",
            contentType: 'application/json; charset=utf-8',
            data: JSON.stringify(d)
        }).done(function (json) {
            var html = $("#technical_index").val() + ' of ' + $("#technical_total").val() + " - " + json.CompanyName;
            $("#technical_csv_log").html(html);
            $tbl.flexReload2();
        }).always(function () {
        });
    });
 
    $("body").on("click", "#chkIsBookMarkCategory", function () {
        $tbl.flexReload2();
    });      

    $("body").on("click", "#lnkRefresh", function () {
        $tbl.flexReload2();
    });
     
});