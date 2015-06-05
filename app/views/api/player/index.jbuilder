
json.players @players.each do |player|
  json.(:name, )
end

json.players @players, :name, :site, :position, :salary
