import 'package:checkin/services/bloc/auth-bloc/auth_bloc.dart';
import 'package:checkin/services/bloc/auth-bloc/auth_event.dart';
import 'package:checkin/services/bloc/auth-bloc/auth_state.dart';
import 'package:checkin/services/bloc/checkin-bloc/checkin_bloc.dart';
import 'package:checkin/widgets/custom-feild.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String upperCaseName = '';
  Future<bool> _showLogoutDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Log Out'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                BlocProvider.of<AuthBloc>(context).add(LogoutEvent());
                Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login', (Route<dynamic> route) => false);
              },
              child: const Text('Log Out'),
            ),
          ],
        );
      },
    ).then((value) => value ?? false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        title: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is Authenticated) {
              String email = state.email;
              String userName = email.split('@')[0];
              upperCaseName = userName.toUpperCase();

              return Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.deepPurple,
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    upperCaseName,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ],
              );
            } else {
              return const Text('Home');
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'Checkin'),
                Tab(text: 'History'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  CheckInTab(),
                  HistoryTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CheckInTab extends StatefulWidget {
  const CheckInTab({
    super.key,
  });
  @override
  State<CheckInTab> createState() => _CheckInTabState();
}

class _CheckInTabState extends State<CheckInTab> {
  final TextEditingController _notesController = TextEditingController();
  bool _gambledToday =
      false; // Add a boolean variable to track the switch state
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          return Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Gambled Today',
                        style:
                            TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Switch(
                        value: _gambledToday,
                        onChanged: (value) {
                          setState(() {
                            _gambledToday = value;
                          });
                        },
                      ),
                    ],
                  ),
                  CustomTextField(
                    hintText: 'Notes',
                    controller: _notesController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter note';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Center(
                    child: SizedBox(
                      width: 120,
                      height: 120,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(
                              20),
                        ),
                        onPressed: () {
                          if(_formKey.currentState!.validate()){
                          String gambledTodayValue =
                              _gambledToday ? 'yes' : 'no';

                          context.read<CheckInBloc>().add(
                                AddCheckIn(
                                  _notesController.text,
                                  state.email,
                                  gambledTodayValue,
                                ),
                              );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Check-in recorded!'),
                              duration: Duration(milliseconds: 500),
                            ),
                          );
                          setState(() {
                            _notesController.clear();
                            _gambledToday = false;
                          });}
                        },
                        child: const Text(
                          'Check In',
                          style: TextStyle(fontSize: 14), // Adjusted font size
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Switch(
                      value: _gambledToday,
                      onChanged: (value) {
                        setState(() {
                          _gambledToday = value; // Update the switch state
                        });
                      },
                    ),
                    const Text('Gambled Today'),
                  ],
                ),
                CustomTextField(
                    hintText: 'Notes', controller: _notesController),
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  width: 120,
                  height: 120,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding:
                          const EdgeInsets.all(20), // Slightly reduced padding
                    ),
                    onPressed: () {
                      String gambledTodayValue =
                          _gambledToday ? 'yes' : 'no';

                      context.read<CheckInBloc>().add(
                            AddCheckIn(
                              _notesController.text,
                              'Guest',
                              gambledTodayValue,
                            ),
                          );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Check-in recorded!'),
                          duration: Duration(milliseconds: 500),
                        ),
                      );
                      setState(() {
                        _notesController.clear();
                        _gambledToday = false;
                      });
                    },
                    child: const Text(
                      'Check In',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}

class HistoryTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CheckInBloc, CheckInState>(
      builder: (context, state) {
        if (state is CheckInLoaded) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (state.checkIns.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete All Check-ins'),
                          content: const Text(
                              'Are you sure you want to delete all check-ins?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel',
                                  style: TextStyle(color: Colors.grey)),
                            ),
                            TextButton(
                              onPressed: () {
                                context
                                    .read<CheckInBloc>()
                                    .add(DeleteAllCheckIns());
                                Navigator.pop(context);
                              },
                              child: const Text('Delete All',
                                  style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    label: const Text('Delete All'),
                    icon: const Icon(Icons.delete),
                  ),
                ),
              if (state.checkIns.isEmpty)
                const Expanded(
                  child: Center(
                    child: Text(
                      'No check-ins available',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: state.checkIns.length,
                    itemBuilder: (context, index) {
                      final checkIn = state.checkIns[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ListTile(
                          title: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const CircleAvatar(
                                    backgroundColor: Colors.deepPurple,
                                    child: Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 20.0),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          checkIn.username.toUpperCase(),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                              fontSize: 20),
                                        ),
                                        Text(
                                          checkIn.name,
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 12),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines:
                                              1,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 10.0,
                              ),
                              Row(
                                children: [
                                  const CircleAvatar(
                                    backgroundColor: Colors.deepPurple,
                                    child: Icon(
                                      Icons.casino,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 20.0,
                                  ),
                                  Text(
                                    checkIn.gambled.toUpperCase(),
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 15),
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 10.0,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const CircleAvatar(
                                        backgroundColor: Colors.deepPurple,
                                        child: Icon(
                                          Icons.date_range,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 20.0,
                                      ),
                                      Text(
                                        '${checkIn.time.day}/${checkIn.time.month}/${checkIn.time.year} ',
                                        style: const TextStyle(
                                            color: Colors.black, fontSize: 15),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const CircleAvatar(
                                        backgroundColor: Colors.deepPurple,
                                        child: Icon(
                                          Icons.hourglass_bottom,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 20.0,
                                      ),
                                      Text(
                                        '${checkIn.time.hour}:${checkIn.time.minute.toString().padLeft(2, '0')}',
                                        style: const TextStyle(
                                            color: Colors.black, fontSize: 15),
                                      )
                                    ],
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
