require 'pg'
require 'librato/metrics'

url = ENV['PGBOUNCER_URL'] || 'postgres://pgbouncer@%2Ftmp:6000/pgbouncer'
interval = ENV['PGBOUNCER_MONITOR_INTERVAL']&.to_i || 10
librato_source = ENV['DYNO']

Librato::Metrics.authenticate ENV['LIBRATO_USER'], ENV['LIBRATO_TOKEN']

conn = PGconn.open(url)

keys = %w(cl_active cl_waiting sv_active sv_idle sv_used sv_tested sv_login maxwait)

loop do
  res  = conn.exec('SHOW POOLS')
  res.each do |row|
    queue = Librato::Metrics::Queue.new
    keys.each do |k|
      queue.add "pgbouncer.#{row['database']}.#{k}": { source: librato_source, value: row[k] }
    end
    queue.submit
  end

  sleep interval
end