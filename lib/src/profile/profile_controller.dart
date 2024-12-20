// import 'package:oauth2_client/oauth2_helper.dart';

// class ProfileController {
//   final OAuth2Helper oauth2Helper;

//   ProfileController({required this.oauth2Helper});

//   Future<ProfileModel> fetchProfileData() async {
//     // Use the oauth2Helper to make a Spotify API call
//     final response = await oauth2Helper.get(
//       'https://api.spotify.com/v1/me', // Spotify API endpoint for user profile
//     );

//     if (response.statusCode == 200) {
//       final data = response.data; // Adjust based on your HTTP library
//       return ProfileModel(
//         displayName: data['display_name'],
//         email: data['email'],
//         profileImageUrl: data['images'][0]['url'],
//       );
//     } else {
//       throw Exception('Failed to fetch profile data: ${response.statusCode}');
//     }
//   }

//   Future<bool> logout() async {
//     // Clear any saved tokens or session data as necessary
//     return true;
//   }
// }
