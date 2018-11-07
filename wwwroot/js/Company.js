
function Company() {
    var self = this;

    this.index = -1;
    this.company_json = null;

    this.start = function () {
        console.log('self.index=', self.index);
        var symbols = '';
        for (var i = 0; i < self.company_json.length; i++) {
            var c = self.company_json[i];
            symbols += c.CompanyID + '|' + c.InvestingUrl + '|' + formatDate(c.LastTradingDate, 'DD/MM/YYYY') + '|' + formatDate(new Date(), 'DD/MM/YYYY') + ',';
        }
        if (symbols != '') {
            symbols = symbols.substring(0, symbols.length - 1);
        }
        if (symbols != '') {
            console.log('call gccmd', symbols);
            var $gcb_cmd = $("#gcb_cmd");
            $gcb_cmd.attr("cmd", "investing-history");
            $gcb_cmd.attr("symbol", symbols);
            $gcb_cmd.click();
        }
    }

}

var _COMPANY = new Company();

$(function () {
    var $tbl = $("#tblCompany");

    $tbl.flexigrid2({
        usepager: true,
        useBoxStyle: false,
        url: apiUrl("/Company/List"),
        rpOptions: [5, 10, 20, 30, 40, 50, 100, 200, 500, 1000],
        rp: 1000,
        onSubmit: function (p) {
            p.params = [];
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

    var $lnkInvestingDownload = $("#lnkInvestingDownload");

    $lnkInvestingDownload.click(function () {
        _COMPANY.start();
    });

    var $btnInvestingUpdateCSV = $("#btnInvestingUpdateCSV");
    $btnInvestingUpdateCSV.click(function () {
        var $investing_csv = $("#investing_csv");
        console.log('investing_csv=', $investing_csv.val());
        var url = apiUrl("/Company/UpdateCSV");
        var d = { "csv": $investing_csv.val() };
        $.ajax({
            "url": url,
            "cache": false,
            "type": "POST",
            contentType : 'application/json; charset=utf-8',
            data: JSON.stringify(d)
        }).done(function (json) {
            var html = $("#investing_index").val() + ' of ' + $("#investing_total").val() + " - " + json.CompanyName;
            $("#investing_csv_log").html(html);
        }).always(function () {
        });
    });


});