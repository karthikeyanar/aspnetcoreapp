$(function () {
    var $tbl = $("#tblMonthly");
    var $fromDate = $(":input[name='FromDate']");
    
    $fromDate.val(getMonthFirstDate(new Date()));
    $fromDate.datepicker({
        changeMonth: true,
        changeYear: true,
        onSelect: function (dateText) {
            console.log(dateText);
            $fromDate.val(dateText);
            $tbl.flexReload2();
        }
    });
   
    $tbl.flexigrid2({
        usepager: true,
        useBoxStyle: false,
        url: apiUrl("/Report/Monthly"),
        rpOptions: [10, 20, 30, 40, 50, 100, 200],
        rp: 10,
        onSubmit: function (p) {
            p.params = [];
            p.params.push({ 'name': 'IsBookMarkCategory', 'value': $('#chkIsBookMarkCategory')[0].checked });
            p.params.push({ 'name': 'FromDate', 'value': $(":input[name='FromDate']").val() });
        },
        onSuccess: function (t, g) { },
        onTemplate: function (data) {
            var tbody = $("tbody", $tbl);
            tbody.empty();
            var avg = 0;
            var total = 0;
            for(var i=0;i<data.rows.length;i++){
                total += cFloat(data.rows[i].Percentage);
            }
            avg = total/data.rows.length;
            $("#lnkAverage").html(formatNumber(avg)+'%');
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
        sortname: "his.prevpercentage",
        sortorder: "desc",
        autoload: true,
        height: 0,
        applyFixedHeader: true
    });
});