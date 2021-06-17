library single_searchable_dropdown;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'removeSignVietnamese.dart';

/// Usage:
// SingleSearchableDropdown(
//   datas: [1, 2, 3, 4],
//   onSelected: (item) {},
// ),
class SingleSearchableDropdown<T> extends StatefulWidget {
  SingleSearchableDropdown({
    Key key,
    @required this.datas,
    @required this.onSelected,
    this.hintText = 'Tất cả',
    this.closedText = 'Đóng',
    this.autoFocusSearchField = true,
  }) : super(key: key);

  /// data
  List<T> datas;

  /// hint text
  String hintText;

  /// close button text
  String closedText;

  /// on selected item callback
  void Function(T item) onSelected;

  /// auto focus text field search
  bool autoFocusSearchField;

  @override
  _SingleSearchableDropdownState<T> createState() => new _SingleSearchableDropdownState();
}

class _SingleSearchableDropdownState<T> extends State<SingleSearchableDropdown<T>> {
  String _showText = '';

  @override
  void initState() {
    _showText = widget.hintText;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        await showDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) {
            return DropdownDialog(
              datas: widget.datas,
              closedText: widget.closedText,
              autoFocusSearchField: widget.autoFocusSearchField,
            );
          },
        ).then((selectedItem) {
          if (selectedItem != null) {
            widget.onSelected(selectedItem);
            setState(() {
              _showText = selectedItem.toString();
            });
          }
        });
      },
      child: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              _showText,
              style: TextStyle(fontSize: 16),
            ),
          ),
          Icon(Icons.arrow_drop_down),
        ],
      ),
    );
  }
}

class DropdownDialog<T> extends StatefulWidget {
  DropdownDialog({
    Key key,
    @required this.datas,
    @required this.closedText,
    @required this.autoFocusSearchField,
  }) : super(key: key);

  List<T> datas;
  String closedText;
  bool autoFocusSearchField;

  _DropdownDialogState<T> createState() => new _DropdownDialogState<T>();
}

class _DropdownDialogState<T> extends State<DropdownDialog> {
  TextEditingController txtSearch = new TextEditingController();
  TextStyle defaultButtonStyle = new TextStyle(fontSize: 16, fontWeight: FontWeight.w500);

  List<T> _searchData = [];

  @override
  void initState() {
    _searchData = widget.datas;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      padding: MediaQuery.of(context).viewInsets,
      duration: const Duration(milliseconds: 300),
      child: new Card(
        color: Colors.white,
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: new Container(
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _searchBar(),
              _listView(),
              _closedButton(),
            ],
          ),
        ),
      ),
    );
  }

  //======= child widget

  Widget _searchBar() {
    return new Container(
      child: new Stack(
        children: <Widget>[
          new TextField(
            controller: txtSearch,
            decoration: InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 32, vertical: 12)),
            autofocus: widget.autoFocusSearchField,
            onChanged: (keyword) {
              _onChangedSearch(keyword);

              setState(() {});
            },
          ),
          new Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: new Center(
              child: new Icon(
                Icons.search,
                size: 24,
              ),
            ),
          ),
          txtSearch.text.isNotEmpty
              ? new Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: new Center(
                    child: new InkWell(
                      onTap: () {
                        setState(() {
                          txtSearch.text = '';
                          _onChangedSearch('');
                        });
                      },
                      borderRadius: BorderRadius.all(Radius.circular(32)),
                      child: new Container(
                        width: 32,
                        height: 32,
                        child: new Center(
                          child: new Icon(
                            Icons.close,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : new Container(),
        ],
      ),
    );
  }

  Widget _listView() {
    return Expanded(
      child: ListView.builder(
        itemCount: _searchData.length,
        itemBuilder: (context, index) {
          T currentItem = _searchData[index];

          return InkWell(
            onTap: () {
              Navigator.of(context).pop(currentItem);
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Text(
                currentItem.toString(),
                style: TextStyle(fontSize: 16),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _closedButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FlatButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Container(
              child: Text(
            "Đóng",
            style: defaultButtonStyle,
            overflow: TextOverflow.ellipsis,
          )),
        )
      ],
    );
  }

  void _onChangedSearch(String keyword) {
    if (keyword.trim().isNotEmpty) {
      _searchData = [];
      widget.datas.forEach((element) {
        //== search condition
        if (RemoveSignVietNameseUtil.removeDiacritics(element.toString().toLowerCase())
            .contains(RemoveSignVietNameseUtil.removeDiacritics(keyword.toLowerCase()))) {
          _searchData.add(element);
        }
      });
    } else {
      _searchData = widget.datas;
    }
  }
}
