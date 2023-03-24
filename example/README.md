# Introduction

A demonstration app to communicate flutter app with turtlesim node in ROS using ROSBridge

## Summary

### Main Page
![Main Page](https://raw.githubusercontent.com/youngmin-gwon/ros_dart/main/example/assets/main.png)

### Parameter and Service call
![Service Before](https://raw.githubusercontent.com/youngmin-gwon/ros_dart/main/example/assets/param_service1.png)
![Service After](https://raw.githubusercontent.com/youngmin-gwon/ros_dart/main/example/assets/param_service2.png)

**Initialization**

```dart
  @override
  void initState() {
    super.initState();
    _ros = Ros(uri: Uri.parse('your-uri-for-example-ws://172.0.0.1:8080'));
    _service = RosService(
      ros: _ros,
      name: '/your_service_name',
      type: 'your_service/data_type',
    );
    _param = RosParam(ros: _ros, name: '/your_param');
    _ros.connect();
  }

  @override
  void dispose() {
    _ros.close();
    super.dispose();
  }
```

**Service & Parameter call**

```dart
  void _serviceCall() {
      // _param.get().then((value) => print(value));
      _param.set('your_param');
      _service.call({'your-data-type':'it can be what ever'});
    }
```

### Topic
![Topic](https://raw.githubusercontent.com/youngmin-gwon/ros_dart/main/example/assets/topic.png)

**Initialization**

```dart
  @override
  void initState() {
    super.initState();
    _ros = Ros(uri: Uri.parse('your-uri-for-example-ws://172.0.0.1:8080'));
    _topic = RosTopic(
      ros: _ros,
      name: '/your_topic/whatever_it_can_be',
      type: 'your_data_type/Whatever',
    );
    _ros.connect();
  }

  @override
  void dispose() {
    _ros.close();
    super.dispose();
  }
```

**Service & Parameter call**

```dart
  void _topic() {
    _topic.publish({
      'your_data': {'whatever':'it_can_be'},
    });
    }
```
