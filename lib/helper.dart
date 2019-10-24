import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirrortask/scsettings.dart';
import 'package:mirrortask/scstart.dart';

/*----------------------------------------------------------------------------*/

const divx_0 = SizedBox(width: 5,);
const divx_1 = SizedBox(width: 10,);
const divx_2 = SizedBox(width: 20,);
const divx_3 = SizedBox(width: 40,);
const divx_4 = SizedBox(width: 80,);
const divy_0 = SizedBox(height: 5,);
const divy_1 = SizedBox(height: 10,);
const divy_2 = SizedBox(height: 20,);
const divy_3 = SizedBox(height: 40,);
const divy_4 = SizedBox(height: 80,);

const coldef_lcbcgreen1 = Color(0xffC6DA85);
const coldef_lcbcgreen2 = Color(0xff95C21A);
const coldef_lcbcblue2  = Color(0xFF00A0E4);
const coldef_lcbcblue1  = Color(0xFF00B2EC);

/*----------------------------------------------------------------------------*/

class LcScaffold extends StatelessWidget {
  final Widget body;
  final List<Widget> actions;
  final Function onNext;

  LcScaffold({
    this.body,
    this.actions: const [],
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _CustomAppBar(
        actions: actions,
      ),
      body: body,
      floatingActionButton: 
        onNext != null
          ? FloatingActionButton(onPressed: onNext,child: Icon(Icons.navigate_next),) 
          : null,
    );
  }

  static Widget getActionSettings(context) {
  return IconButton(
    icon: Icon(Icons.settings,),
      onPressed: () {
          Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SettingsScreen(),
          )
        );
      },
    );
  }

  static Widget getActionReset(context) {
  return IconButton(
    icon: Icon(Icons.cancel,),
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) => CupertinoAlertDialog(
            title: Text("Close the test?"),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true, 
                child: Text("Close test"),
                isDestructiveAction: true,
                onPressed: () async {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => StartScreen(),
                    )
                  );
                },
              ),
              CupertinoDialogAction(
                isDefaultAction: true, 
                child: Text("Back"),
                isDestructiveAction: false,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

/*----------------------------------------------------------------------------*/

class _CustomAppBar extends StatelessWidget implements PreferredSizeWidget {

  final List<Widget> actions;

  _CustomAppBar({
    this.actions
  });

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return  Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [coldef_lcbcgreen1, coldef_lcbcgreen2, coldef_lcbcblue2, coldef_lcbcblue1],
          stops: [0.0, 0.25, 0.75, 1],
          )
        ),
      child: AppBar(
        actions: actions,
        title: Text("LCBC Mirror Tracing"),
        backgroundColor: Color(0x00000000),
        centerTitle: true,
      ),
    );
  }

}
