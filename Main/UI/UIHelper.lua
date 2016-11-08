----
-- 文件名称：UIHelper.lua
-- 功能描述：UI 辅助接口
-- 文件说明：UI 辅助接口
-- 作    者：王雷雷
-- 创建时间：2016-8-3
--  修改

function CreateTableView(x, y, w, h, dir, obj)
    local gridView = cc.TableView:create(cc.size(w, h))
    gridView:setPosition(cc.p(x, y))
    gridView:setDirection(dir)
    gridView:setVerticalFillOrder(0)
    gridView:setBounceable(true)
    gridView:setDelegate()
    gridView:registerScriptHandler(obj.ScrollViewDidScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)
    gridView:registerScriptHandler(obj.TableCellTouched, cc.TABLECELL_TOUCHED)
    gridView:registerScriptHandler(obj.CellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    gridView:registerScriptHandler(obj.TableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    gridView:registerScriptHandler(obj.NumberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    return gridView
end

--带回调函数的
function CreateTableViewWithFun(x, y, w, h, dir, callBackScroll, callbackCellTouch, callbackSize, callbackGet, callbackNumber)
    local gridView = cc.TableView:create(cc.size(w, h))
    gridView:setPosition(cc.p(x, y))
    gridView:setDirection(dir)
    gridView:setVerticalFillOrder(0)
    gridView:setBounceable(true)
    gridView:setDelegate()
    gridView:registerScriptHandler(callBackScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)
    gridView:registerScriptHandler(callbackCellTouch, cc.TABLECELL_TOUCHED)
    gridView:registerScriptHandler(callbackSize, cc.TABLECELL_SIZE_FOR_INDEX)
    gridView:registerScriptHandler(callbackGet, cc.TABLECELL_SIZE_AT_INDEX)
    gridView:registerScriptHandler(callbackNumber, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    return gridView
end