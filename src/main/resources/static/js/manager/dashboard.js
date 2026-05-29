document.addEventListener('DOMContentLoaded', function() {
    const ctx = document.getElementById('revenueChart').getContext('2d');
    
    // Gradient for the bars (optional, but looks nice)
    // const gradient = ctx.createLinearGradient(0, 0, 0, 400);
    // gradient.addColorStop(0, '#0056b3');
    // gradient.addColorStop(1, '#004494');

    new Chart(ctx, {
        type: 'bar',
        data: {
            labels: ['Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4', 'Tháng 5', 'Tháng 6'],
            datasets: [{
                label: 'Doanh thu',
                data: [3900, 3000, 2000, 2800, 1900, 2400],
                backgroundColor: '#0056b3',
                borderRadius: 4,
                barThickness: 60, // Adjust depending on width
                maxBarThickness: 80
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    display: false // Hide legend to match design
                },
                tooltip: {
                    callbacks: {
                        label: function(context) {
                            let label = context.dataset.label || '';
                            if (label) {
                                label += ': ';
                            }
                            if (context.parsed.y !== null) {
                                label += new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(context.parsed.y);
                            }
                            return label;
                        }
                    }
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    max: 4000,
                    ticks: {
                        stepSize: 1000,
                        callback: function(value) {
                            return '$' + value;
                        },
                        color: '#6c757d',
                        font: {
                            family: 'Inter',
                            size: 12
                        }
                    },
                    border: {
                        display: false
                    },
                    grid: {
                        color: '#dee2e6',
                        drawTicks: false,
                        borderDash: [5, 5] // Dashed lines for the grid
                    }
                },
                x: {
                    grid: {
                        display: false,
                        drawBorder: false
                    },
                    ticks: {
                        color: '#6c757d',
                        font: {
                            family: 'Inter',
                            size: 12
                        }
                    },
                    border: {
                        display: false
                    }
                }
            }
        }
    });
});
