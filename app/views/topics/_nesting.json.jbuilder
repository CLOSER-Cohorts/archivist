json.extract! topic, :id, :name, :code
json.children topic.children, partial: 'topics/nesting', as: :topic