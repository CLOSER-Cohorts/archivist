class Children
  include Enumerable
  extend Forwardable

  def_delegators :to_ary, :last

  def initialize(assocs)
    @cc_conditions = assocs[:cc_conditions]
    @cc_loops      = assocs[:cc_loops]
    @cc_questions  = assocs[:cc_questions]
    @cc_sequences  = assocs[:cc_sequences]
    @cc_statements = assocs[:cc_statements]
  end

  def <<(new_child)
    case new_child
      when CcCondition
        @cc_conditions.reader << new_child
      when CcLoop
        @cc_loops.reader << new_child
      when CcQuestion
        @cc_questions.reader << new_child
      when CcSequence
        @cc_sequences.reader << new_child
      when CcStatement
        @cc_statements.reader << new_child
    end
  end

  def each(&block)
    to_ary.each &block
  end

  def to_ary
    (
      @cc_conditions.reader +
      @cc_loops.reader  +
      @cc_questions.reader  +
      @cc_sequences.reader  +
      @cc_statements.reader
    ).sort_by { |cc| [cc.branch.to_i, cc.position.to_i] }
  end
end