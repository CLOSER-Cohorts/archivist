desc 'Generate Entity Relationship Diagram'
task :generate_erd do
  system "erd --inheritance --filetype=dot --notation=bachman --orientation=vertical --direct --attributes=foreign_keys,content"
  system "dot -Tpng erd.dot > erd.png"
  File.delete('erd.dot')
end

desc 'Generate Entity Relationship Diagram but without Instrument'
task :generate_erd_woi do
    system "erd --inheritance --exclude=Instrument --filetype=dot --notation=bachman --orientation=horizontal --direct --attributes=foreign_keys,content"
      system "dot -Tpng erd.dot > erd-woi.png"
        File.delete('erd.dot')
end

desc 'Generate Entity Relationship Diagram with Polymorphism'
task :generate_erd_wp do
    system "erd --inheritance --filetype=dot --notation=bachman --polymorphism=true --direct --attributes=foreign_keys,content"
      system "dot -Tpng erd.dot > erd-wp.png"
        File.delete('erd.dot')
end
