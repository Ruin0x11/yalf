local refactoring_visitor = {}

function refactoring_visitor:new(refactorings)
   local marked = {}
   for i, _ in ipairs(refactorings) do
      marked[i] = {}
   end

   local o = setmetatable({ refactorings = refactorings, marked = marked }, { __index = refactoring_visitor })
   self.is_preorder = true
   return o
end

function refactoring_visitor:visit_leaf(node)
   for i, tbl in ipairs(self.marked) do
      local ref = self.refactorings[i]
      if ref:applies_to(node) then
         tbl[#tbl+1] = node
      end
   end
end

function refactoring_visitor:visit_node(node, visit)
   if self.is_preorder then
      visit(self, node, visit)
   end

   for i, tbl in ipairs(self.marked) do
      if self.refactorings[i]:applies_to(node) then
         tbl[#tbl+1] = node
      end
   end

   if not self.is_preorder then
      visit(self, node, visit)
   end
end

function refactoring_visitor:refactor()
   for i, nodes in ipairs(self.marked) do
      local ref = self.refactorings[i]
      for _, node in ipairs(nodes) do
         ref:execute(node)
      end
   end
end

return refactoring_visitor
