
function Investments() {
    var self = this;

    this.index = -1;   

    this.applyPieChart = function(rows){
        var pieData = [];
        var categories = [];
        var totalInvestment = 0;
        var totalCMV = 0;
        for(var i = 0;i<rows.length;i++){
            var row = rows[i];
            totalInvestment += cFloat(row.TotalInvestment);
            totalCMV += cFloat(row.CurrentMarketValue);
            var cat = null;
            for(var j = 0;j<categories.length;j++){
                if(categories[j].category_name == row.CategoryName) {
                    cat = categories[j];
                }
            }
            if(cat==null) {
                cat = {"category_name":row.CategoryName,"investment":cFloat(row.TotalInvestment),"fmv":cFloat(row.CurrentMarketValue)};
                categories.push(cat);
            } else {
                cat.investment = cFloat(cat.investment) + cFloat(row.TotalInvestment);
                cat.fmv = cFloat(cat.fmv) + cFloat(row.CurrentMarketValue);
            }
        }
        for(var j = 0;j<categories.length;j++){
            categories[j].invpercent = cFloat(categories[j].investment) / cFloat(totalInvestment) * 100;
            categories[j].fmvpercent = cFloat(categories[j].fmv) / cFloat(totalCMV) * 100;
        }
        console.log('categories=',categories);
        var pieData = [];
        for(var j = 0;j<categories.length;j++){
            pieData.push({
                name: categories[j].category_name,y: categories[j].invpercent
            }); 
        }
        var profitData = [];
        for(var j = 0;j<categories.length;j++){
            profitData.push({
                name: categories[j].category_name,y: categories[j].fmvpercent
            }); 
        }
        // Build the chart
        Highcharts.chart('piecontainer', {
            chart: {
                plotBackgroundColor: null,
                plotBorderWidth: null,
                plotShadow: false,
                type: 'pie'
            },
            title: {
                text: 'Investments'
            },
            tooltip: {
                pointFormat: '{series.name}: <b>{point.percentage:.1f}%</b>'
            },
            accessibility: {
                point: {
                    valueSuffix: '%'
                }
            },
            plotOptions: {
                pie: {
                    allowPointSelect: true,
                    cursor: 'pointer',
                    dataLabels: {
                        enabled: true,
                        format: '<b>{point.name}</b>: {point.percentage:.1f} %'
                    }
                }
            },
            series: [{
                name: 'Investments',
                data: pieData
            }]
        });

        // Build the chart
        Highcharts.chart('profitcontainer', {
            chart: {
                plotBackgroundColor: null,
                plotBorderWidth: null,
                plotShadow: false,
                type: 'pie'
            },
            title: {
                text: 'Profits'
            },
            tooltip: {
                pointFormat: '{series.name}: <b>{point.percentage:.1f}%</b>'
            },
            accessibility: {
                point: {
                    valueSuffix: '%'
                }
            },
            plotOptions: {
                pie: {
                    allowPointSelect: true,
                    cursor: 'pointer',
                    dataLabels: {
                        enabled: true,
                        format: '<b>{point.name}</b>: {point.percentage:.1f} %'
                    }
                }
            },
            series: [{
                name: 'Profits',
                data: profitData
            }]
        });
    }
}

var _Investments = new Investments();

$(function () {
    var $tbl = $("#tblInvestments");

    $tbl.flexigrid2({
        usepager: true,
        useBoxStyle: false,
        url: apiUrl("/Portfolio/Investments"),
        rpOptions: [200, 500, 1000,2000],
        rp: 200,
        onSubmit: function (p) {
            p.params = [];
        },
        onSuccess: function (t, g) { },
        onTemplate: function (data) {
            var tbody = $("tbody", $tbl);
            tbody.empty();
            $("#grid-template").tmpl(data).appendTo(tbody);
            var totalInvestment = 0;
            var totalCMV = 0;
            for(var i = 0;i<data.rows.length;i++){
                totalInvestment += cFloat(data.rows[i].TotalInvestment);
                totalCMV += cFloat(data.rows[i].CurrentMarketValue);
            }
            var p = ((totalCMV - totalInvestment) / totalInvestment) * 100;
            $("#spnTotalInvestment").html(formatNumber(totalInvestment,4));
            $("#spnTotalCMV").html(formatNumber(totalCMV,4));
            console.log('p=',p);
            $("#spnTotalProfit").html(formatNumber(p,4) + '&nbsp;%');
            _Investments.applyPieChart(data.rows);
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
        sortname: "ProfitPercentage",
        sortorder: "desc",
        autoload: true,
        height: 0,
        applyFixedHeader: true
    });
  
    $("body").on("click", "#lnkRefresh", function () {
        $tbl.flexReload2();
    });

});