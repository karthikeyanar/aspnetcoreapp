
function SplitCheck() {
    var self = this;
}

var _SPLITCHECK = new SplitCheck();

$(function () {
    var $tbl = $("#tbl");

    $tbl.flexigrid2({
        usepager: true,
        useBoxStyle: false,
        url: apiUrl("/Company/SplitCheck"),
        rpOptions: [10, 20, 30, 40, 50, 100, 200, 500, 1000],
        rp: 1000,
        onSubmit: function (p) {
            p.params = [];
        },
        onSuccess: function (t, g) { },
        onTemplate: function (data) {
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
        sortname: "",
        sortorder: "",
        autoload: true,
        height: 0,
        applyFixedHeader: true
    });

    $("body").on("click", ".split-row", function () {
        var $this = $(this);
        var $tr = $this.parents("tr:first");
        var companyId = $("#CompanyID", $tr).val();
        var splitFactor = $("#SplitFactor", $tr).val();
        var splitDate = formatDate($("#SplitDate", $tr).val());

        var arr = [];
        var url = apiUrl("/Company/CreateSplit");
        var d = { 'CompanyID': companyId, 'SplitFactor': splitFactor, 'SplitDate': splitDate };
        console.log('d=', d);
        $.ajax({
            "url": url,
            "cache": false,
            "type": "POST",
            contentType: 'application/json; charset=utf-8',
            data: JSON.stringify(d)
        }).done(function (json) {
            $tbl.flexReload2();
        }).always(function () {
        });
    });

    $("body").on("click", "#lnkRefresh", function () {
        $tbl.flexReload2();
    });


});