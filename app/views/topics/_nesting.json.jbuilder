json.extract! topic, :id, :name, :code, :description
json.children topic.children, partial: 'topics/nesting', as: :topic
