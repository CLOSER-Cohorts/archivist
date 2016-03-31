json.extract! topic, :id, :name
json.children topic.children, partial: 'topics/nesting', as: :topic